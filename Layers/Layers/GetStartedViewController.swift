//
//  GetStartedViewController.swift
//  Layers
//
//  Created by David Hodge on 4/11/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import ObjectMapper

class GetStartedViewController: UIViewController
{
    @IBOutlet weak var connectWithFacebookButton: UIButton!
    
    @IBOutlet weak var useEmailButton: UIButton!
    
    @IBOutlet weak var tryItButton: UIButton!
    
    @IBOutlet weak var logoLabel: UILabel!
    
    @IBOutlet weak var heroImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Email"

        logoLabel.font = Font.CharterBold(size: 30.0)
        view.sendSubviewToBack(heroImage)
        
        connectWithFacebookButton.addTarget(self, action: #selector(connectWithFacebook), forControlEvents: .TouchUpInside)

        useEmailButton.addTarget(self, action: #selector(useEmail), forControlEvents: .TouchUpInside)
        
        tryItButton.addTarget(self, action: #selector(tryIt), forControlEvents: .TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        connectWithFacebookButton.userInteractionEnabled = true
        useEmailButton.userInteractionEnabled = true
        tryItButton.userInteractionEnabled = true
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func connectWithFacebook()
    {
        connectWithFacebookButton.userInteractionEnabled = false
        
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
                            
                            if let response = Mapper<FacebookUserResponse>().map(attributes)
                            {
                                // Send Facebook Login Credentials to the API
                                
                                log.debug(response.toJSONString())
                            }
                            
                            AppStateTransitioner.transitionToMainStoryboard(true)
                        }
                    })
                }
            }
        })
    }
    
    func useEmail()
    {
        useEmailButton.userInteractionEnabled = false
        
        performSegueWithIdentifier("ShowEmailChoiceViewController", sender: self)
    }
    
    func tryIt()
    {
        tryItButton.userInteractionEnabled = false
        
        AppStateTransitioner.transitionToMainStoryboard(true)
    }
}
