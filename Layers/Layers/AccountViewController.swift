//
//  AccountViewController.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class AccountViewController: UIViewController
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "LAYERS".uppercaseString
        
        tabBarItem.title = "account".uppercaseString
        tabBarItem.image = UIImage(named: "person")
        tabBarItem.image = UIImage(named: "person-filled")
    }
}