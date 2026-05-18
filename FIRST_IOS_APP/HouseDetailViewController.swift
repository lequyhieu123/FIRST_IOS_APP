import UIKit
import FirebaseFirestore

class HouseDetailViewController: UIViewController,
                                 UITableViewDataSource,
                                 UITableViewDelegate
{
    @IBOutlet weak var houseNameLabel: UILabel!
    @IBOutlet weak var customerNameField: UITextField!
    @IBOutlet weak var addressField: UITextField!

    @IBOutlet weak var totalRoomsLabel: UILabel!
    @IBOutlet weak var doneRoomsLabel: UILabel!
    @IBOutlet weak var undoneRoomsLabel: UILabel!

    @IBOutlet weak var roomTableView: UITableView!
    @IBOutlet weak var newRoomNameField: UITextField!

    var house: House?
    var rooms = [Room]()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        roomTableView.dataSource = self
        roomTableView.delegate = self

        showHouseDetails()
        loadRooms()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        loadRooms()
    }

    func showHouseDetails()
    {
        guard let house = house else
        {
            return
        }

        houseNameLabel.text = house.nickname
        customerNameField.text = house.customerName
        addressField.text = house.address
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

    @IBAction func saveHousePressed(_ sender: Any)
    {
        guard let houseId = house?.documentID else
        {
            return
        }

        let customerName = customerNameField.text ?? ""
        let address = addressField.text ?? ""

        let db = Firestore.firestore()

        db.collection("houses").document(houseId).updateData([
            "customerName": customerName,
            "address": address
        ])
        { error in

            if let error = error
            {
                print("Error saving house: \(error)")
            }
            else
            {
                print("House saved")
                self.showMessage(title: "Saved", message: "House information has been saved.")
            }
        }
    }

    func loadRooms()
    {
        guard let houseId = house?.documentID else
        {
            return
        }

        let db = Firestore.firestore()

        db.collection("houses")
            .document(houseId)
            .collection("rooms")
            .getDocuments()
        { result, error in

            if let error = error
            {
                print("Error loading rooms: \(error)")
                return
            }

            self.rooms.removeAll()

            let documents = result?.documents ?? []

            for document in documents
            {
                let room = Room(
                    documentID: document.documentID,
                    data: document.data()
                )

                self.rooms.append(room)
            }

            self.updateRoomStats()
            self.roomTableView.reloadData()
        }
    }

    func updateRoomStats()
    {
        let total = rooms.count
        let done = rooms.filter { $0.done }.count
        let undone = total - done

        totalRoomsLabel.text = "Total rooms: \(total)"
        doneRoomsLabel.text = "Done: \(done)"
        undoneRoomsLabel.text = "Undone: \(undone)"
    }

    @IBAction func addRoomPressed(_ sender: Any)
    {
        guard let houseId = house?.documentID else
        {
            return
        }

        let roomName = newRoomNameField.text ?? ""
        let cleanName = roomName.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanName.isEmpty
        {
            showMessage(title: "Missing room name", message: "Please enter a room name.")
            return
        }

        let db = Firestore.firestore()

        let newRoom = Room(
            name: cleanName,
            done: false
        )

        db.collection("houses")
            .document(houseId)
            .collection("rooms")
            .addDocument(data: newRoom.toDictionary())
        { error in

            if let error = error
            {
                print("Error adding room: \(error)")
            }
            else
            {
                print("Room added")
                self.newRoomNameField.text = ""
                self.loadRooms()
            }
        }
    }

    @IBAction func viewQuotePressed(_ sender: Any)
    {
        performSegue(withIdentifier: "showQuote", sender: house)
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        return rooms.count
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
            withIdentifier: "RoomTableViewCell",
            for: indexPath
        ) as! RoomTableViewCell

        let room = rooms[indexPath.row]

        cell.roomNameLabel.text = room.name
        cell.doneSwitch.isOn = room.done

        cell.editButton.setTitle("Edit", for: .normal)
        cell.deleteButton.setTitle("X", for: .normal)
        cell.arrowButton.setTitle(">", for: .normal)

        cell.doneSwitch.tag = indexPath.row
        cell.editButton.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row
        cell.arrowButton.tag = indexPath.row

        cell.doneSwitch.removeTarget(nil, action: nil, for: .allEvents)
        cell.editButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.deleteButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.arrowButton.removeTarget(nil, action: nil, for: .allEvents)

        cell.doneSwitch.addTarget(
            self,
            action: #selector(roomDoneChanged(_:)),
            for: .valueChanged
        )

        cell.editButton.addTarget(
            self,
            action: #selector(editRoomPressed(_:)),
            for: .touchUpInside
        )

        cell.deleteButton.addTarget(
            self,
            action: #selector(deleteRoomPressed(_:)),
            for: .touchUpInside
        )

        cell.arrowButton.addTarget(
            self,
            action: #selector(openRoomPressed(_:)),
            for: .touchUpInside
        )

        return cell
    }

    @objc func roomDoneChanged(_ sender: UISwitch)
    {
        guard let houseId = house?.documentID else
        {
            return
        }

        let room = rooms[sender.tag]

        guard let roomId = room.documentID else
        {
            return
        }

        let db = Firestore.firestore()

        db.collection("houses")
            .document(houseId)
            .collection("rooms")
            .document(roomId)
            .updateData([
                "done": sender.isOn
            ])
        { error in

            if let error = error
            {
                print("Error updating room done status: \(error)")
            }
            else
            {
                self.loadRooms()
            }
        }
    }

    @objc func editRoomPressed(_ sender: UIButton)
    {
        let room = rooms[sender.tag]

        let alert = UIAlertController(
            title: "Edit Room",
            message: "Change the room name.",
            preferredStyle: .alert
        )

        alert.addTextField
        { textField in
            textField.text = room.name
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

            self.updateRoomName(room: room, newName: cleanName)
        })

        present(alert, animated: true, completion: nil)
    }

    func updateRoomName(room: Room, newName: String)
    {
        guard let houseId = house?.documentID else
        {
            return
        }

        guard let roomId = room.documentID else
        {
            return
        }

        let db = Firestore.firestore()

        db.collection("houses")
            .document(houseId)
            .collection("rooms")
            .document(roomId)
            .updateData([
                "name": newName
            ])
        { error in

            if let error = error
            {
                print("Error updating room: \(error)")
            }
            else
            {
                self.loadRooms()
            }
        }
    }

    @objc func deleteRoomPressed(_ sender: UIButton)
    {
        let room = rooms[sender.tag]

        let alert = UIAlertController(
            title: "Delete Room",
            message: "Are you sure you want to delete this room?",
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

            self.deleteRoom(room: room)
        })

        present(alert, animated: true, completion: nil)
    }

    func deleteRoom(room: Room)
    {
        guard let houseId = house?.documentID else
        {
            return
        }

        guard let roomId = room.documentID else
        {
            return
        }

        let db = Firestore.firestore()

        db.collection("houses")
            .document(houseId)
            .collection("rooms")
            .document(roomId)
            .delete()
        { error in

            if let error = error
            {
                print("Error deleting room: \(error)")
            }
            else
            {
                self.loadRooms()
            }
        }
    }

    @objc func openRoomPressed(_ sender: UIButton)
    {
        let room = rooms[sender.tag]
        performSegue(withIdentifier: "showRoomDetail", sender: room)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showRoomDetail"
        {
            if let roomScreen = segue.destination as? RoomDetailViewController
            {
                roomScreen.house = house
                roomScreen.room = sender as? Room
            }
        }

        if segue.identifier == "showQuote"
        {
            if let quoteScreen = segue.destination as? QuoteViewController
            {
                quoteScreen.house = house
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
