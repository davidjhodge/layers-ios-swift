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
import DeviceKit

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
        
        logoLabel.attributedText = NSAttributedString(string: "LAYERS".uppercased(), attributes: [NSFontAttributeName:Font.PrimaryFontSemiBold(size: 30.0),
            NSKernAttributeName:3])
        
        view.sendSubview(toBack: heroImage)
        
        facebookButton.setBackgroundColor(Color.white, forState: UIControlState())
        facebookButton.setBackgroundColor(Color.HighlightedWhiteColor, forState: .highlighted)
        
        facebookButton.addTarget(self, action: #selector(connectWithFacebook), for: .touchUpInside)
        
        getStartedButton.setBackgroundColor(Color.NeonBlueColor, forState: UIControlState())
        getStartedButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .highlighted)
        
        getStartedButton.addTarget(self, action: #selector(startBrowsing), for: .touchUpInside)

        alreadyHasAccountButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        if Device() == .iPhone4s
        {
            copyLabel.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        enableButtons()
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: Actions
    func connectWithFacebook()
    {
        FBSDKAppEvents.logEvent("GetStarted Facebook Button Taps")

        disableButttons()
        
        UIApplication.shared.setStatusBarStyle(.default, animated: true)

        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: ["public_profile", "user_friends", "email"], from: self, handler: {(result:FBSDKLoginManagerLoginResult?, error:Error?) -> Void in
            
            if error != nil
            {
                log.debug(error?.localizedDescription)
                
                self.enableButtons()
            }
            else if (result?.isCancelled)!
            {
                log.debug("User cancelled Facebook Login")
                
                self.enableButtons()
            }
            else
            {
                log.debug("User successfully logged in with Facebook!")
                
                // Facebook token now exists and can be accessed at FBSDKAccessToken.currentAccessToken()
                
                self.handleFacebookLogin()
                
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    self.disableButttons()
                })
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
              
                UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
            })
        })
    }
    
    func handleFacebookLogin()
    {
        LRSessionManager.sharedManager.connectWithFacebook({ (success, error, response) -> Void in
            
            if success
            {
                // User login succeeded. Note that this means an account already existed
                self.authenticationDidSucceed()
                                
                DispatchQueue.main.async(execute: { () -> Void in
                  
                    AppStateTransitioner.transitionToMainStoryboard(true)
                })
            }
            else
            {
                //User login failed, continue with registration
                LRSessionManager.sharedManager.fetchFacebookUserInfo( { (success, error, result) -> Void in
                    
                    if success
                    {
                        log.debug("Facebook Registration Integration Complete.")
                        
                        FBSDKAppEvents.logEvent("Get Started Facebook Registrations")

                        // Show Confirmation Screen
                        let loginStoryboard = UIStoryboard(name: "Login", bundle: Bundle.main)
                        if let confirmFacebookVc = loginStoryboard.instantiateViewController(withIdentifier: "ConfirmFacebookInfoViewController") as? ConfirmFacebookInfoViewController
                        {
                            if let facebookResponse = result as? FacebookUserResponse
                            {
                                confirmFacebookVc.facebookResponse = facebookResponse
                            }
                            
                            DispatchQueue.main.async(execute: { () -> Void in
                                
                                self.navigationController?.pushViewController(confirmFacebookVc, animated: true)
                            })
                        }
                        
                        return
                    }
                    else
                    {
                        self.enableButtons()

                        DispatchQueue.main.async(execute: { () -> Void in
                            
                            let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
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
        let loginStoryboard = UIStoryboard(name: "Login", bundle: Bundle.main)
        
        if let emailLoginVc = loginStoryboard.instantiateViewController(withIdentifier: "EmailLoginViewController") as? EmailLoginViewController
        {
            emailLoginVc.delegate = self
            
            let nav = UINavigationController(rootViewController: emailLoginVc)
            
            // Show Login
            present(nav, animated: true, completion: nil)
            
            // Hide nav bar on Get Started Screen
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func completeFirstLaunchExperience()
    {
        LRSessionManager.sharedManager.completeFirstLaunch()
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            AppStateTransitioner.transitionToMainStoryboard(true)
        })
    }
    
    // MARK: AuthenticationDelegate
    func authenticationDidSucceed() {
        
        FBSDKAppEvents.logEvent("Get Started Email Registrations")

        completeFirstLaunchExperience()
    }
    
    func userDidCancelAuthentication()
    {
        print("User cancelled authentication.")
    }
    
    // MARK: Handle UI Interactivity
    func disableButttons()
    {
        facebookButton.isUserInteractionEnabled = false
        getStartedButton.isUserInteractionEnabled = false
        alreadyHasAccountButton.isUserInteractionEnabled = false
    }
    
    func enableButtons()
    {
        facebookButton.isUserInteractionEnabled = true
        getStartedButton.isUserInteractionEnabled = true
        alreadyHasAccountButton.isUserInteractionEnabled = true
    }
}
