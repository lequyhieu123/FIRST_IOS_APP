import UIKit

class HouseTableViewCell: UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var arrowButton: UIButton!

    override func awakeFromNib()
    {
        super.awakeFromNib()

        nameLabel.numberOfLines = 2

        editButton.setTitle("Edit", for: .normal)
        deleteButton.setTitle("X", for: .normal)
        arrowButton.setTitle(">", for: .normal)
    }
}
