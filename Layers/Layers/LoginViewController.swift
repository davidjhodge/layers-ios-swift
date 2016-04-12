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
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var emailLoginButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        logoLabel.font = Font.CharterBold(size: 30.0)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()

        googleLoginButton.userInteractionEnabled = true
        emailLoginButton.userInteractionEnabled = true
    }
    
    @IBAction func loginWithGoogle(sender: AnyObject)
    {
        googleLoginButton.userInteractionEnabled = true

        AppStateTransitioner.transitionToMainStoryboard(true)
    }
    
    @IBAction func loginWithEmail(sender: AnyObject)
    {
        emailLoginButton.userInteractionEnabled = true
    performSegueWithIdentifier("ShowEmailLoginViewController", sender: self)
    }
    
}