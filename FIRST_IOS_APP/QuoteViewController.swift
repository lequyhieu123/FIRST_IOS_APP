import UIKit
import FirebaseFirestore

class QuoteViewController: UIViewController
{
    @IBOutlet weak var customerInfoLabel: UILabel!
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var houseTotalLabel: UILabel!

    var house: House?

    var quoteText = ""
    var houseTotal = 0.0

    let labourCostPerRoom = 200.0

    override func viewDidLoad()
    {
        super.viewDidLoad()

        quoteTextView.isEditable = false
        quoteTextView.text = ""

        loadQuote()
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

    @IBAction func recalculatePressed(_ sender: Any)
    {
        loadQuote()
    }

    @IBAction func printReceiptPressed(_ sender: Any)
    {
        let customerInfo = customerInfoLabel.text ?? ""
        let quoteDetails = quoteTextView.text ?? ""
        let houseTotalText = houseTotalLabel.text ?? ""

        let shareText =
        """
        QUOTE RECEIPT

        \(customerInfo)

        \(quoteDetails)

        \(houseTotalText)
        """

        if shareText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        {
            showMessage(
                title: "Nothing to Share",
                message: "There is no quote data to share."
            )
            return
        }

        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )

        if let popover = activityViewController.popoverPresentationController
        {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        present(activityViewController, animated: true, completion: nil)
    }

    func loadQuote()
    {
        guard let house = house else
        {
            customerInfoLabel.text = "No house selected."
            quoteTextView.text = ""
            houseTotalLabel.text = "House Total: $0.00"
            return
        }

        customerInfoLabel.text =
            "Customer: \(house.customerName)\n" +
            "Address: \(house.address)\n" +
            "Date: \(getTodayDate())"

        quoteText = ""
        houseTotal = 0.0

        guard let houseId = house.documentID else
        {
            quoteTextView.text = "Missing house ID."
            houseTotalLabel.text = "House Total: $0.00"
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
                print("Error loading rooms for quote: \(error)")
                self.quoteTextView.text = "Error loading quote."
                return
            }

            let roomDocuments = result?.documents ?? []

            if roomDocuments.isEmpty
            {
                self.quoteTextView.text = "No rooms found."
                self.houseTotalLabel.text = "House Total: $0.00"
                return
            }

            let group = DispatchGroup()

            for roomDocument in roomDocuments
            {
                group.enter()

                let room = Room(
                    documentID: roomDocument.documentID,
                    data: roomDocument.data()
                )

                self.loadRoomQuote(
                    houseId: houseId,
                    room: room
                )
                {
                    group.leave()
                }
            }

            group.notify(queue: .main)
            {
                self.quoteTextView.text = self.quoteText

                self.houseTotalLabel.text = String(
                    format: "House Total: $%.2f",
                    self.houseTotal
                )
            }
        }
    }

    func loadRoomQuote(
        houseId: String,
        room: Room,
        completion: @escaping () -> Void
    )
    {
        guard let roomId = room.documentID else
        {
            completion()
            return
        }

        let db = Firestore.firestore()

        var roomText = ""
        var roomTotal = 0.0

        roomText += "Room: \(room.name)\n"
        roomText += "-------------------------\n"

        let group = DispatchGroup()

        group.enter()

        db.collection("houses")
            .document(houseId)
            .collection("rooms")
            .document(roomId)
            .collection("windows")
            .getDocuments()
        { result, error in

            if let error = error
            {
                print("Error loading windows for quote: \(error)")
                group.leave()
                return
            }

            let documents = result?.documents ?? []

            for document in documents
            {
                let window = WindowSpace(
                    documentID: document.documentID,
                    data: document.data()
                )

                let area = (window.width / 1000.0) * (window.height / 1000.0)
                let price = area * window.materialPrice

                roomTotal += price

                roomText += String(
                    format: "Window: %@\nMaterial: %@\n$%.2f\n\n",
                    window.name,
                    window.materialName,
                    price
                )
            }

            group.leave()
        }

        group.enter()

        db.collection("houses")
            .document(houseId)
            .collection("rooms")
            .document(roomId)
            .collection("floors")
            .getDocuments()
        { result, error in

            if let error = error
            {
                print("Error loading floors for quote: \(error)")
                group.leave()
                return
            }

            let documents = result?.documents ?? []

            for document in documents
            {
                let floor = FloorSpace(
                    documentID: document.documentID,
                    data: document.data()
                )

                let area = (floor.width / 1000.0) * (floor.length / 1000.0)
                let price = area * floor.materialPrice

                roomTotal += price

                roomText += String(
                    format: "Floor: %@\nMaterial: %@\n$%.2f\n\n",
                    floor.name,
                    floor.materialName,
                    price
                )
            }

            group.leave()
        }

        group.notify(queue: .main)
        {
            roomTotal += self.labourCostPerRoom

            roomText += String(
                format: "Labour\n$%.2f\n\n",
                self.labourCostPerRoom
            )

            roomText += String(
                format: "Room Total\n$%.2f\n\n\n",
                roomTotal
            )

            self.houseTotal += roomTotal
            self.quoteText += roomText

            completion()
        }
    }

    func getTodayDate() -> String
    {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
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
