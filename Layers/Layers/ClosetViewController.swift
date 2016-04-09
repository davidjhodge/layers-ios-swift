//
//  ClosetViewController.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class ClosetViewController: UIViewController
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "LAYERS".uppercaseString
        
        tabBarItem.title = "my closet".uppercaseString
        tabBarItem.image = UIImage(named: "coathanger")
        tabBarItem.image = UIImage(named: "coathanger-filled")
    }
}