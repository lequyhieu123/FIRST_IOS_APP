//
//  RoomDetailViewController.swift
//  FIRST_IOS_APP
//
//  Created by Trà My Dương on 18/5/2026.
//

import UIKit

class RoomDetailViewController: UIViewController
{
    var house: House?
    var room: Room?

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if let room = room
        {
            print("Opened room: \(room.name)")
        }
    }
}
