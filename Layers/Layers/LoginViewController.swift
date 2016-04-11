//
//  LoginViewController.swift
//  Layers
//
//  Created by David Hodge on 4/11/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController
{
    @IBOutlet weak var logoLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        logoLabel.font = Font.CharterBold(size: 30.0)
    }
    
    @IBAction func loginWithGoogle(sender: AnyObject)
    {
        
    }
    
    @IBAction func loginWithEmail(sender: AnyObject)
    {
        performSegueWithIdentifier("ShowEmailLoginViewController", sender: self)
    }
    
}