//
//  QuoteViewController.swift
//  FIRST_IOS_APP
//
//  Created by Trà My Dương on 18/5/2026.
//

import UIKit

class QuoteViewController: UIViewController
{
    var house: House?

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if let house = house
        {
            print("Opened quote for: \(house.nickname)")
        }
    }
}
