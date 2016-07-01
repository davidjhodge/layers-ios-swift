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

class GetStartedViewController: UIViewController, AuthenticationDelegate
{
    @IBOutlet weak var getStartedButton: UIButton!

    @IBOutlet weak var alreadyHasAccountButton: UIButton!
    
    @IBOutlet weak var logoLabel: UILabel!
    
    @IBOutlet weak var heroImage: UIImageView!
    
    @IBOutlet weak var facebookButton: UIButton!
    
    @IBOutlet weak var copyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoLabel.attributedText = NSAttributedString(string: "LAYERS".uppercaseString, attributes: [NSFontAttributeName:Font.CharterBold(size: 30.0),
            NSKernAttributeName:3])
        
        view.sendSubviewToBack(heroImage)
        
        facebookButton.addTarget(self, action: #selector(connectWithFacebook), forControlEvents: .TouchUpInside)
        
        getStartedButton.addTarget(self, action: #selector(startBrowsing), forControlEvents: .TouchUpInside)

        alreadyHasAccountButton.addTarget(self, action: #selector(login), forControlEvents: .TouchUpInside)
        
        if UIDevice.currentDevice().type == .iPhone4S
        {
            copyLabel.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        enableButtons()
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: Actions
    func connectWithFacebook()
    {
        FBSDKAppEvents.logEvent("GetStarted Facebook Button Taps")

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
                
                // Facebook token now exists and can be accessed at FBSDKAccessToken.currentAccessToken()
                
                LRSessionManager.sharedManager.fetchFacebookUserInfo( { (success, error, result) -> Void in
                    
                    if success
                    {
                        log.debug("Facebook Registration Integration Complete.")
                        
                        FBSDKAppEvents.logEvent("Get Started Facebook Registrations")

                        // Show Confirmation Screen
                        let loginStoryboard = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
                        if let confirmFacebookVc = loginStoryboard.instantiateViewControllerWithIdentifier("ConfirmFacebookInfoViewController") as? ConfirmFacebookInfoViewController
                        {
                            if let facebookResponse = result as? FacebookUserResponse
                            {
                                confirmFacebookVc.facebookResponse = facebookResponse
                            }
                            
                            self.navigationController?.pushViewController(confirmFacebookVc, animated: true)
                        }
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                    }
                })
            }
        })
    }
    
    func startBrowsing()
    {
        FBSDKAppEvents.logEvent("GetStarted Start Browsing Button Taps")

        disableButttons()
        
        completeFirstLaunchExperience()
    }
    
    func login()
    {
        FBSDKAppEvents.logEvent("GetStarted Login Button Taps")
        
        disableButttons()
        
        // Show Email Login View Controller
        let loginStoryboard = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
        
        if let emailLoginVc = loginStoryboard.instantiateViewControllerWithIdentifier("EmailLoginViewController") as? EmailLoginViewController
        {
            emailLoginVc.delegate = self
            
            let nav = UINavigationController(rootViewController: emailLoginVc)
            
            // Show Login
            presentViewController(nav, animated: true, completion: nil)
            
            // Hide nav bar on Get Started Screen
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func completeFirstLaunchExperience()
    {
        LRSessionManager.sharedManager.completeFirstLaunch()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            AppStateTransitioner.transitionToMainStoryboard(true)
        })
    }
    
    // MARK: AuthenticationDelegate
    func authenticationDidSucceed() {
        
        FBSDKAppEvents.logEvent("Get Started Email Registrations")

        completeFirstLaunchExperience()
    }
    
    // MARK: Handle UI Interactivity
    func disableButttons()
    {
        getStartedButton.userInteractionEnabled = false
        alreadyHasAccountButton.userInteractionEnabled = false
    }
    
    func enableButtons()
    {
        getStartedButton.userInteractionEnabled = true
        alreadyHasAccountButton.userInteractionEnabled = true
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowOnboardingContainerViewController"
        {
            navigationController?.setNavigationBarHidden(true, animated: false)
            
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
        }
    }
}
