import UIKit
import FirebaseFirestore

class HouseListViewController: UIViewController,
                               UITableViewDataSource,
                               UITableViewDelegate,
                               UISearchBarDelegate
{
    @IBOutlet weak var houseCountLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var houseTableView: UITableView!
    @IBOutlet weak var newHouseNameField: UITextField!

    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var notStartedButton: UIButton!
    @IBOutlet weak var newHouseButton: UIButton!

    var houses = [House]()
    var filteredHouses = [House]()
    var houseStatusMap = [String: String]()

    var currentFilter = "ALL"

    override func viewDidLoad()
    {
        super.viewDidLoad()

        houseTableView.dataSource = self
        houseTableView.delegate = self
        searchBar.delegate = self

        loadHouses()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        loadHouses()
    }

    @IBAction func backPressed(_ sender: Any)
    {
        if let navigationController = navigationController
        {
            navigationController.popViewController(animated: true)
        }
        else
        {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func allPressed(_ sender: Any)
    {
        currentFilter = "ALL"
        applySearchAndFilter()
    }

    @IBAction func donePressed(_ sender: Any)
    {
        currentFilter = "DONE"
        applySearchAndFilter()
    }

    @IBAction func progressPressed(_ sender: Any)
    {
        currentFilter = "PROGRESS"
        applySearchAndFilter()
    }

    @IBAction func notStartedPressed(_ sender: Any)
    {
        currentFilter = "NOT_STARTED"
        applySearchAndFilter()
    }

    @IBAction func addHousePressed(_ sender: Any)
    {
        let nickname = newHouseNameField.text ?? ""
        let cleanName = nickname.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanName.isEmpty
        {
            showMessage(
                title: "Missing name",
                message: "Please enter a house nickname."
            )
            return
        }

        let db = Firestore.firestore()

        let data: [String: Any] = [
            "nickname": cleanName,
            "customerName": "",
            "address": "",
            "createdAt": Date(),
            "updatedAt": Date()
        ]

        db.collection("houses").addDocument(data: data)
        { error in

            if let error = error
            {
                print("Error adding house: \(error)")
            }
            else
            {
                print("House added")
                self.newHouseNameField.text = ""
                self.loadHouses()
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        applySearchAndFilter()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }

    func loadHouses()
    {
        let db = Firestore.firestore()

        db.collection("houses").getDocuments()
        { result, error in

            if let error = error
            {
                print("Error loading houses: \(error)")
                return
            }

            self.houses.removeAll()
            self.houseStatusMap.removeAll()

            let documents = result?.documents ?? []

            if documents.isEmpty
            {
                self.applySearchAndFilter()
                return
            }

            for document in documents
            {
                let house = House(
                    documentID: document.documentID,
                    data: document.data()
                )

                self.houses.append(house)
            }

            // Sort by newest updated/opened/added first
            self.houses.sort
            { first, second in

                let firstDate = first.updatedAt ?? Date.distantPast
                let secondDate = second.updatedAt ?? Date.distantPast

                return firstDate > secondDate
            }

            self.loadAllHouseStatuses()
        }
    }

    func loadAllHouseStatuses()
    {
        let group = DispatchGroup()

        for house in houses
        {
            guard let houseId = house.documentID else
            {
                continue
            }

            group.enter()

            loadHouseStatus(houseId: houseId)
            { status in
                self.houseStatusMap[houseId] = status
                group.leave()
            }
        }

        group.notify(queue: .main)
        {
            self.applySearchAndFilter()
        }
    }

    func loadHouseStatus(houseId: String, completion: @escaping (String) -> Void)
    {
        let db = Firestore.firestore()

        db.collection("houses")
            .document(houseId)
            .collection("rooms")
            .getDocuments()
        { result, error in

            if let error = error
            {
                print("Error loading rooms for status: \(error)")
                completion("EMPTY")
                return
            }

            let rooms = result?.documents ?? []

            if rooms.isEmpty
            {
                completion("EMPTY")
                return
            }

            var doneCount = 0

            for roomDocument in rooms
            {
                let data = roomDocument.data()
                let done = data["done"] as? Bool ?? false

                if done
                {
                    doneCount += 1
                }
            }

            if doneCount == 0
            {
                completion("NOT_STARTED")
            }
            else if doneCount == rooms.count
            {
                completion("DONE")
            }
            else
            {
                completion("PROGRESS")
            }
        }
    }

    func applySearchAndFilter()
    {
        let searchText = searchBar.text?.lowercased() ?? ""

        filteredHouses = houses.filter
        { house in

            let matchesSearch = searchText.isEmpty ||
                house.nickname.lowercased().contains(searchText)

            var matchesFilter = true

            if currentFilter != "ALL"
            {
                let houseId = house.documentID ?? ""
                let status = houseStatusMap[houseId] ?? "EMPTY"
                matchesFilter = status == currentFilter
            }

            return matchesSearch && matchesFilter
        }

        houseCountLabel.text = "Total houses: \(houses.count)"
        houseTableView.reloadData()
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        return filteredHouses.count
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 56
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "HouseTableViewCell",
            for: indexPath
        ) as! HouseTableViewCell

        let house = filteredHouses[indexPath.row]

        cell.nameLabel.text = house.nickname
        cell.editButton.setTitle("Edit", for: .normal)
        cell.deleteButton.setTitle("X", for: .normal)
        cell.arrowButton.setTitle(">", for: .normal)

        let houseId = house.documentID ?? ""
        let status = houseStatusMap[houseId] ?? "EMPTY"

        switch status
        {
        case "EMPTY":
            cell.contentView.backgroundColor = UIColor.systemGray5

        case "NOT_STARTED":
            cell.contentView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.25)

        case "PROGRESS":
            cell.contentView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.35)

        case "DONE":
            cell.contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.25)

        default:
            cell.contentView.backgroundColor = UIColor.systemGray5
        }

        cell.editButton.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row
        cell.arrowButton.tag = indexPath.row

        cell.editButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.deleteButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.arrowButton.removeTarget(nil, action: nil, for: .allEvents)

        cell.editButton.addTarget(
            self,
            action: #selector(editHousePressed(_:)),
            for: .touchUpInside
        )

        cell.deleteButton.addTarget(
            self,
            action: #selector(deleteHousePressed(_:)),
            for: .touchUpInside
        )

        cell.arrowButton.addTarget(
            self,
            action: #selector(openHousePressed(_:)),
            for: .touchUpInside
        )

        return cell
    }

    @objc func editHousePressed(_ sender: UIButton)
    {
        let house = filteredHouses[sender.tag]

        let alert = UIAlertController(
            title: "Edit House",
            message: "Change the house nickname.",
            preferredStyle: .alert
        )

        alert.addTextField
        { textField in
            textField.text = house.nickname
        }

        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))

        alert.addAction(UIAlertAction(
            title: "Save",
            style: .default)
        { action in

            let newName = alert.textFields?[0].text ?? ""
            let cleanName = newName.trimmingCharacters(in: .whitespacesAndNewlines)

            if cleanName.isEmpty
            {
                return
            }

            guard let houseId = house.documentID else
            {
                return
            }

            let db = Firestore.firestore()

            db.collection("houses").document(houseId).updateData([
                "nickname": cleanName,
                "updatedAt": Date()
            ])
            { error in

                if let error = error
                {
                    print("Error updating house: \(error)")
                }
                else
                {
                    print("House updated")
                    self.loadHouses()
                }
            }
        })

        present(alert, animated: true, completion: nil)
    }

    @objc func deleteHousePressed(_ sender: UIButton)
    {
        let house = filteredHouses[sender.tag]

        let alert = UIAlertController(
            title: "Delete House",
            message: "Are you sure you want to delete this house?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))

        alert.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive)
        { action in

            guard let houseId = house.documentID else
            {
                return
            }

            let db = Firestore.firestore()

            db.collection("houses").document(houseId).delete()
            { error in

                if let error = error
                {
                    print("Error deleting house: \(error)")
                }
                else
                {
                    print("House deleted")
                    self.loadHouses()
                }
            }
        })

        present(alert, animated: true, completion: nil)
    }

    @objc func openHousePressed(_ sender: UIButton)
    {
        let house = filteredHouses[sender.tag]

        if let houseId = house.documentID
        {
            Firestore.firestore()
                .collection("houses")
                .document(houseId)
                .updateData([
                    "updatedAt": Date()
                ])
            { error in

                if let error = error
                {
                    print("Error updating opened house time: \(error)")
                }
            }
        }

        performSegue(withIdentifier: "showHouseDetail", sender: house)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showHouseDetail"
        {
            if let detailScreen = segue.destination as? HouseDetailViewController
            {
                detailScreen.house = sender as? House
            }
        }
    }

    func showMessage(title: String, message: String)
    {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        ))

        present(alert, animated: true, completion: nil)
    }
}
