import UIKit

class RoomTableViewCell: UITableViewCell
{
    @IBOutlet weak var doneSwitch: UISwitch!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var arrowButton: UIButton!

    override func awakeFromNib()
    {
        super.awakeFromNib()

        roomNameLabel.numberOfLines = 2
    }
}
