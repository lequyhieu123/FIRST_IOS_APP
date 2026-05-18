import UIKit

class HouseDetailViewController: UIViewController
{
    var house: House?

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if let house = house
        {
            print("Opened house: \(house.nickname)")
        }
    }
}
