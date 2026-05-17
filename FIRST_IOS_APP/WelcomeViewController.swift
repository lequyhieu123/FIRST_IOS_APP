import UIKit

class WelcomeViewController: UIViewController
{
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var okButton: UIButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        okButton.layer.cornerRadius = 12
        okButton.clipsToBounds = true
    }

    @IBAction func okPressed(_ sender: Any)
    {
        let name = nameField.text ?? ""

        if name.isEmpty
        {
            let alert = UIAlertController(
                title: "Missing Name",
                message: "Please enter your name.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil
            ))

            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            print("User entered name: \(name)")
        }
    }
}
