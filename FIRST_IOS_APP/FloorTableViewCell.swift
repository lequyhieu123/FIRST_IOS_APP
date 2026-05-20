import UIKit

class FloorTableViewCell: UITableViewCell
{
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        infoLabel.numberOfLines = 2
    }
}
