//
//  LoginViewController.swift
//  Layers
//
//  Created by David Hodge on 4/11/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController
{
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var facebookLoginButton: UIButton!
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

        facebookLoginButton.userInteractionEnabled = true
        emailLoginButton.userInteractionEnabled = true
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject)
    {
        facebookLoginButton.userInteractionEnabled = false

        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        
        loginManager.logInWithReadPermissions(["public_profile", "user_friends", "email"], fromViewController: self, handler: {(result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            
            if error != nil
            {
                log.debug(error.localizedDescription)
            }
            else if result.isCancelled
            {
                log.debug("User cancelled Facebook Login")
            }
            else
            {
                log.debug("User successfully logged in with Facebook!")
                
                let fbAccessToken = result.token.tokenString
                
                if (FBSDKAccessToken.currentAccessToken() != nil)
                {
                    let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, age_range, link, gender, locale, picture, timezone, updated_time, verified, friends, email"], HTTPMethod: "GET")

                    request.startWithCompletionHandler({(connection:FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                  
                        if error == nil
                        {
                            let attributes: Dictionary<String,AnyObject> = result as! Dictionary<String,AnyObject>
                            
                            let gender = result["gender"]
                        
                        }
                    })
                }
            }
        })
        
//        AppStateTransitioner.transitionToMainStoryboard(true)
    }
    
    @IBAction func loginWithEmail(sender: AnyObject)
    {
        emailLoginButton.userInteractionEnabled = false
    performSegueWithIdentifier("ShowEmailLoginViewController", sender: self)
    }
    
}