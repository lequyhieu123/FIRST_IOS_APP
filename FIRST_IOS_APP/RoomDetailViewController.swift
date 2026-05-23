import UIKit
import FirebaseFirestore

class RoomDetailViewController: UIViewController,
                                UITableViewDataSource,
                                UITableViewDelegate,
                                UIImagePickerControllerDelegate,
                                UINavigationControllerDelegate
{
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var windowTableView: UITableView!
    @IBOutlet weak var floorTableView: UITableView!

    @IBOutlet weak var roomImageView: UIImageView!
    @IBOutlet weak var choosePhotoButton: UIButton!

    var house: House?
    var room: Room?

    var windows = [WindowSpace]()
    var floors = [FloorSpace]()

    let windowMaterials: [(name: String, price: Double)] = [
        ("Standard Glass", 25.0),
        ("Double Glazed Glass", 45.0),
        ("Tinted Glass", 35.0),
        ("Security Glass", 55.0)
    ]

    let floorMaterials: [(name: String, price: Double)] = [
        ("Carpet", 30.0),
        ("Laminate", 40.0),
        ("Timber", 65.0),
        ("Tile", 55.0)
    ]

    override func viewDidLoad()
    {
        super.viewDidLoad()

        windowTableView.dataSource = self
        windowTableView.delegate = self

        floorTableView.dataSource = self
        floorTableView.delegate = self

        roomNameLabel.text = room?.name

        roomImageView.contentMode = .scaleAspectFit
        roomImageView.clipsToBounds = true

        loadWindows()
        loadFloors()
        loadRoomImage()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        loadWindows()
        loadFloors()
        loadRoomImage()
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

    @IBAction func addWindowPressed(_ sender: Any)
    {
        chooseWindowMaterial(window: nil)
    }

    @IBAction func addFloorPressed(_ sender: Any)
    {
        chooseFloorMaterial(floor: nil)
    }

    @IBAction func choosePhotoPressed(_ sender: Any)
    {
        print("Choose photo button clicked")

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false

            present(picker, animated: true, completion: nil)
        }
        else
        {
            showMessage(
                title: "Photo Library Unavailable",
                message: "The photo library is not available on this device."
            )
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        picker.dismiss(animated: true, completion: nil)

        guard let selectedImage = info[.originalImage] as? UIImage else
        {
            showMessage(
                title: "Image Error",
                message: "Could not select this image."
            )
            return
        }

        roomImageView.image = selectedImage
        saveRoomImageToFirestore(selectedImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }

    func saveRoomImageToFirestore(_ image: UIImage)
    {
        guard let roomRef = roomReference() else
        {
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.20) else
        {
            return
        }

        let base64String = imageData.base64EncodedString()

        roomRef.updateData([
            "photoBase64": base64String
        ])
        { error in

            if let error = error
            {
                print("Error saving room photo: \(error)")
            }
            else
            {
                print("Room photo saved")
            }
        }
    }

    func loadRoomImage()
    {
        guard let roomRef = roomReference() else
        {
            return
        }

        roomRef.getDocument()
        { document, error in

            if let error = error
            {
                print("Error loading room photo: \(error)")
                return
            }

            guard let data = document?.data() else
            {
                return
            }

            guard let base64String = data["photoBase64"] as? String else
            {
                return
            }

            guard let imageData = Data(base64Encoded: base64String) else
            {
                return
            }

            self.roomImageView.image = UIImage(data: imageData)
        }
    }

    func roomReference() -> DocumentReference?
    {
        guard let houseId = house?.documentID else
        {
            print("Missing house ID")
            return nil
        }

        guard let roomId = room?.documentID else
        {
            print("Missing room ID")
            return nil
        }

        return Firestore.firestore()
            .collection("houses")
            .document(houseId)
            .collection("rooms")
            .document(roomId)
    }

    func loadWindows()
    {
        guard let roomRef = roomReference() else
        {
            print("Cannot load windows")
            return
        }

        roomRef.collection("windows").getDocuments()
        { result, error in

            if let error = error
            {
                print("Error loading windows: \(error)")
                return
            }

            self.windows.removeAll()

            let documents = result?.documents ?? []

            for document in documents
            {
                let window = WindowSpace(
                    documentID: document.documentID,
                    data: document.data()
                )

                self.windows.append(window)
            }

            self.windowTableView.reloadData()
        }
    }

    func loadFloors()
    {
        guard let roomRef = roomReference() else
        {
            print("Cannot load floors")
            return
        }

        roomRef.collection("floors").getDocuments()
        { result, error in

            if let error = error
            {
                print("Error loading floors: \(error)")
                return
            }

            self.floors.removeAll()

            let documents = result?.documents ?? []

            for document in documents
            {
                let floor = FloorSpace(
                    documentID: document.documentID,
                    data: document.data()
                )

                self.floors.append(floor)
            }

            self.floorTableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        if tableView == windowTableView
        {
            return windows.count
        }
        else
        {
            return floors.count
        }
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == windowTableView
        {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "WindowTableViewCell",
                for: indexPath
            ) as! WindowTableViewCell

            let window = windows[indexPath.row]

            cell.infoLabel.text =
                "\(window.name) - \(window.width) x \(window.height)\n" +
                "\(window.materialName) - $\(window.materialPrice)"

            cell.editButton.tag = indexPath.row
            cell.deleteButton.tag = indexPath.row

            cell.editButton.removeTarget(nil, action: nil, for: .allEvents)
            cell.deleteButton.removeTarget(nil, action: nil, for: .allEvents)

            cell.editButton.addTarget(
                self,
                action: #selector(editWindowPressed(_:)),
                for: .touchUpInside
            )

            cell.deleteButton.addTarget(
                self,
                action: #selector(deleteWindowPressed(_:)),
                for: .touchUpInside
            )

            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "FloorTableViewCell",
                for: indexPath
            ) as! FloorTableViewCell

            let floor = floors[indexPath.row]

            cell.infoLabel.text =
                "\(floor.name) - \(floor.width) x \(floor.length)\n" +
                "\(floor.materialName) - $\(floor.materialPrice)"

            cell.editButton.tag = indexPath.row
            cell.deleteButton.tag = indexPath.row

            cell.editButton.removeTarget(nil, action: nil, for: .allEvents)
            cell.deleteButton.removeTarget(nil, action: nil, for: .allEvents)

            cell.editButton.addTarget(
                self,
                action: #selector(editFloorPressed(_:)),
                for: .touchUpInside
            )

            cell.deleteButton.addTarget(
                self,
                action: #selector(deleteFloorPressed(_:)),
                for: .touchUpInside
            )

            return cell
        }
    }

    func chooseWindowMaterial(window: WindowSpace?)
    {
        let alert = UIAlertController(
            title: "Choose Window Material",
            message: "Select one material.",
            preferredStyle: .alert
        )

        for material in windowMaterials
        {
            alert.addAction(UIAlertAction(
                title: "\(material.name) - $\(material.price)",
                style: .default)
            { action in
                self.showWindowDialog(
                    window: window,
                    selectedMaterial: material
                )
            })
        }

        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))

        present(alert, animated: true, completion: nil)
    }

    func chooseFloorMaterial(floor: FloorSpace?)
    {
        let alert = UIAlertController(
            title: "Choose Floor Material",
            message: "Select one material.",
            preferredStyle: .alert
        )

        for material in floorMaterials
        {
            alert.addAction(UIAlertAction(
                title: "\(material.name) - $\(material.price)",
                style: .default)
            { action in
                self.showFloorDialog(
                    floor: floor,
                    selectedMaterial: material
                )
            })
        }

        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))

        present(alert, animated: true, completion: nil)
    }

    @objc func editWindowPressed(_ sender: UIButton)
    {
        let window = windows[sender.tag]
        chooseWindowMaterial(window: window)
    }

    @objc func deleteWindowPressed(_ sender: UIButton)
    {
        let window = windows[sender.tag]

        guard let roomRef = roomReference() else
        {
            return
        }

        guard let windowId = window.documentID else
        {
            return
        }

        roomRef.collection("windows").document(windowId).delete()
        { error in

            if let error = error
            {
                print("Error deleting window: \(error)")
            }
            else
            {
                self.loadWindows()
            }
        }
    }

    @objc func editFloorPressed(_ sender: UIButton)
    {
        let floor = floors[sender.tag]
        chooseFloorMaterial(floor: floor)
    }

    @objc func deleteFloorPressed(_ sender: UIButton)
    {
        let floor = floors[sender.tag]

        guard let roomRef = roomReference() else
        {
            return
        }

        guard let floorId = floor.documentID else
        {
            return
        }

        roomRef.collection("floors").document(floorId).delete()
        { error in

            if let error = error
            {
                print("Error deleting floor: \(error)")
            }
            else
            {
                self.loadFloors()
            }
        }
    }

    func showWindowDialog(
        window: WindowSpace?,
        selectedMaterial: (name: String, price: Double)
    )
    {
        let alert = UIAlertController(
            title: window == nil ? "Add Window" : "Edit Window",
            message: "Material: \(selectedMaterial.name) - $\(selectedMaterial.price)",
            preferredStyle: .alert
        )

        alert.addTextField
        { textField in
            textField.placeholder = "Window name"
            textField.text = window?.name
        }

        alert.addTextField
        { textField in
            textField.placeholder = "Width in mm"
            textField.keyboardType = .decimalPad

            if let width = window?.width
            {
                textField.text = "\(width)"
            }
        }

        alert.addTextField
        { textField in
            textField.placeholder = "Height in mm"
            textField.keyboardType = .decimalPad

            if let height = window?.height
            {
                textField.text = "\(height)"
            }
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

            let name = alert.textFields?[0].text ?? ""
            let widthText = alert.textFields?[1].text ?? ""
            let heightText = alert.textFields?[2].text ?? ""

            let validation = self.validateMeasurementInput(
                name: name,
                widthText: widthText,
                secondText: heightText,
                secondFieldName: "Height"
            )

            if validation.isValid == false
            {
                self.showMessage(
                    title: "Invalid input",
                    message: validation.message
                )
                return
            }

            let newWindow = WindowSpace(
                documentID: window?.documentID,
                name: validation.cleanName,
                width: validation.width,
                height: validation.secondValue,
                materialName: selectedMaterial.name,
                materialPrice: selectedMaterial.price
            )

            self.saveWindow(newWindow)
        })

        present(alert, animated: true, completion: nil)
    }

    func showFloorDialog(
        floor: FloorSpace?,
        selectedMaterial: (name: String, price: Double)
    )
    {
        let alert = UIAlertController(
            title: floor == nil ? "Add Floor" : "Edit Floor",
            message: "Material: \(selectedMaterial.name) - $\(selectedMaterial.price)",
            preferredStyle: .alert
        )

        alert.addTextField
        { textField in
            textField.placeholder = "Floor name"
            textField.text = floor?.name
        }

        alert.addTextField
        { textField in
            textField.placeholder = "Width in mm"
            textField.keyboardType = .decimalPad

            if let width = floor?.width
            {
                textField.text = "\(width)"
            }
        }

        alert.addTextField
        { textField in
            textField.placeholder = "Length in mm"
            textField.keyboardType = .decimalPad

            if let length = floor?.length
            {
                textField.text = "\(length)"
            }
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

            let name = alert.textFields?[0].text ?? ""
            let widthText = alert.textFields?[1].text ?? ""
            let lengthText = alert.textFields?[2].text ?? ""

            let validation = self.validateMeasurementInput(
                name: name,
                widthText: widthText,
                secondText: lengthText,
                secondFieldName: "Length"
            )

            if validation.isValid == false
            {
                self.showMessage(
                    title: "Invalid input",
                    message: validation.message
                )
                return
            }

            let newFloor = FloorSpace(
                documentID: floor?.documentID,
                name: validation.cleanName,
                width: validation.width,
                length: validation.secondValue,
                materialName: selectedMaterial.name,
                materialPrice: selectedMaterial.price
            )

            self.saveFloor(newFloor)
        })

        present(alert, animated: true, completion: nil)
    }

    func validateMeasurementInput(name: String,
                                  widthText: String,
                                  secondText: String,
                                  secondFieldName: String)
    -> (isValid: Bool, message: String, cleanName: String, width: Double, secondValue: Double)
    {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanName.isEmpty
        {
            return (false, "Name cannot be empty.", "", 0, 0)
        }

        if cleanName.count < 2
        {
            return (false, "Name must be at least 2 characters.", "", 0, 0)
        }

        guard let width = Double(widthText) else
        {
            return (false, "Width must be a valid number.", "", 0, 0)
        }

        guard let secondValue = Double(secondText) else
        {
            return (false, "\(secondFieldName) must be a valid number.", "", 0, 0)
        }

        if width <= 0 || secondValue <= 0
        {
            return (false, "Measurements must be greater than 0.", "", 0, 0)
        }

        if width > 20000 || secondValue > 20000
        {
            return (false, "Measurements seem too large. Please enter values under 20000 mm.", "", 0, 0)
        }

        return (true, "", cleanName, width, secondValue)
    }

    func saveWindow(_ window: WindowSpace)
    {
        guard let roomRef = roomReference() else
        {
            return
        }

        if let windowId = window.documentID
        {
            roomRef.collection("windows").document(windowId).updateData(
                window.toDictionary()
            )
            { error in

                if let error = error
                {
                    print("Error updating window: \(error)")
                }
                else
                {
                    self.loadWindows()
                }
            }
        }
        else
        {
            roomRef.collection("windows").addDocument(data: window.toDictionary())
            { error in

                if let error = error
                {
                    print("Error adding window: \(error)")
                }
                else
                {
                    self.loadWindows()
                }
            }
        }
    }

    func saveFloor(_ floor: FloorSpace)
    {
        guard let roomRef = roomReference() else
        {
            return
        }

        if let floorId = floor.documentID
        {
            roomRef.collection("floors").document(floorId).updateData(
                floor.toDictionary()
            )
            { error in

                if let error = error
                {
                    print("Error updating floor: \(error)")
                }
                else
                {
                    self.loadFloors()
                }
            }
        }
        else
        {
            roomRef.collection("floors").addDocument(data: floor.toDictionary())
            { error in

                if let error = error
                {
                    print("Error adding floor: \(error)")
                }
                else
                {
                    self.loadFloors()
                }
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
