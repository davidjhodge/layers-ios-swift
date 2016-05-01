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
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        logoLabel.font = Font.CharterBold(size: 30.0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()

        signUpButton.userInteractionEnabled = true
        loginButton.userInteractionEnabled = true
        
        signUpButton.addTarget(self, action: #selector(signUp), forControlEvents: .TouchUpInside)
        loginButton.addTarget(self, action: #selector(login), forControlEvents: .TouchUpInside)
    }
    
    func signUp()
    {
        signUpButton.userInteractionEnabled = false
        
        performSegueWithIdentifier("ShowEmailCreateAccountViewController", sender: self)
    }
    
    func login()
    {
        loginButton.userInteractionEnabled = false

        performSegueWithIdentifier("ShowEmailLoginViewController", sender: self)
    }
}