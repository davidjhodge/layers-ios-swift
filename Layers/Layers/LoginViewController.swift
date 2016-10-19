//
//  LoginViewController.swift
//  Layers
//
//  Created by David Hodge on 9/3/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import FRHyperLabel
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, AuthenticationDelegate {
    
    @IBOutlet weak var layersLabel: UILabel!
    
    @IBOutlet weak var headlineLabel: UILabel!
    
    @IBOutlet weak var facebookButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var tryItLabel: FRHyperLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        facebookButton.addTarget(self, action: #selector(connectWithFacebook), for: .touchUpInside)
        
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)

        configureAppearance()
    }

    func configureAppearance()
    {
        // Logo
        layersLabel.attributedText = NSAttributedString(string: "layers".uppercased(), attributes: [NSForegroundColorAttributeName: Color.PrimaryAppColor,
            NSFontAttributeName: Font.PrimaryFontRegular(size: 30.0),
            NSKernAttributeName: 4.5
            ])
        
        // Headline
        let headline = "Men's clothing," + "\n" + "curated by the community"
        
        headlineLabel.attributedText = NSAttributedString(string: headline, attributes: [NSForegroundColorAttributeName: Color.GrayColor,
            NSFontAttributeName: Font.PrimaryFontLight(size: 16.0),
            NSKernAttributeName: 0.9])
        
        // Connect with Facebook
        facebookButton.setAttributedTitle(NSAttributedString(string: "Connect with Facebook".uppercased(), attributes: FontAttributes.filledButtonAttributes), for: UIControlState())
        
        facebookButton.setBackgroundColor(Color.PrimaryAppColor, forState: UIControlState())
        facebookButton.setBackgroundColor(Color.HighlightedPrimaryAppColor, forState: .highlighted)
        facebookButton.layer.cornerRadius = 4.0
        facebookButton.clipsToBounds = true
        
        // Sign Up Button
        signUpButton.setBackgroundColor(Color.white, forState: UIControlState())
        signUpButton.setBackgroundColor(Color.PrimaryAppColor, forState: .highlighted)
        
        signUpButton.setAttributedTitle(NSAttributedString(string: "Sign Up".uppercased(), attributes: FontAttributes.buttonAttributes), for: UIControlState())
        signUpButton.setAttributedTitle(NSAttributedString(string: "Sign Up".uppercased(), attributes: FontAttributes.filledButtonAttributes), for: .highlighted)
        
        signUpButton.layer.cornerRadius = 4.0
        signUpButton.clipsToBounds = true
        signUpButton.layer.borderWidth = 1.0
        signUpButton.layer.borderColor = Color.PrimaryAppColor.cgColor
        
        // Login Button
        loginButton.setBackgroundColor(Color.white, forState: UIControlState())
        loginButton.setBackgroundColor(Color.PrimaryAppColor, forState: .highlighted)
        
        loginButton.setAttributedTitle(NSAttributedString(string: "Login".uppercased(), attributes: FontAttributes.buttonAttributes), for: UIControlState())
        loginButton.setAttributedTitle(NSAttributedString(string: "Login".uppercased(), attributes: FontAttributes.filledButtonAttributes), for: .highlighted)

        loginButton.layer.cornerRadius = 4.0
        loginButton.clipsToBounds = true
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = Color.PrimaryAppColor.cgColor
        
        // Try it Label
        tryItLabel.attributedText = tryItLabelAttributedString()
        
        tryItLabel.linkAttributeDefault = [NSForegroundColorAttributeName: Color.PrimaryAppColor,
                                           NSFontAttributeName: Font.PrimaryFontSemiBold(size: 14.0),
                                           NSKernAttributeName: 2.0]
        
        tryItLabel.linkAttributeHighlight = [NSForegroundColorAttributeName: Color.HighlightedPrimaryAppColor,
                                           NSFontAttributeName: Font.PrimaryFontSemiBold(size: 14.0),
                                           NSKernAttributeName: 2.0]
        
        tryItLabel.setLinkForSubstring("Try it first", withLinkHandler: { (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
         
            self.continueAsGuest()
        })
    }
    
    func tryItLabelAttributedString() -> NSAttributedString
    {
        let string = NSMutableAttributedString()
        
        string.append(NSAttributedString(string: "Not quite ready? ", attributes: [
            NSForegroundColorAttributeName: Color.GrayColor,
            NSFontAttributeName: Font.PrimaryFontLight(size: 14.0),
            NSKernAttributeName: 2.0
            ]))
        
        string.append(NSAttributedString(string: "Try it first", attributes: [
            NSForegroundColorAttributeName: Color.PrimaryAppColor,
            NSFontAttributeName: Font.PrimaryFontSemiBold(size: 14.0),
            NSKernAttributeName: 2.0
            ]))
        
        return NSAttributedString(attributedString: string)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: Actions
    
    func connectWithFacebook()
    {
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
        LRSessionManager.sharedManager.loginWithFacebook({ (success, error, response) -> Void in
            
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
                        
                        FBSDKAppEvents.logEvent("Login Facebook Registrations")
                        
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
    
    func signUp()
    {
        FBSDKAppEvents.logEvent("Login - Sign Up Button Taps")
        
        disableButttons()
        
        // Show Email Create Account View Controller
        let loginStoryboard = UIStoryboard(name: "Login", bundle: Bundle.main)
        
        if let emailSignUpVc = loginStoryboard.instantiateViewController(withIdentifier: "EmailCreateAccountViewController") as? EmailCreateAccountViewController
        {
            emailSignUpVc.delegate = self
            
            let nav = UINavigationController(rootViewController: emailSignUpVc)
            
            present(nav, animated: true, completion: nil)
        }
        
    }
    
    func login()
    {
        FBSDKAppEvents.logEvent("Login - Login Button Taps")
        
        disableButttons()
        
        // Show Email Login View Controller
        let loginStoryboard = UIStoryboard(name: "Login", bundle: Bundle.main)
        
        if let emailLoginVc = loginStoryboard.instantiateViewController(withIdentifier: "EmailLoginViewController") as? EmailLoginViewController
        {
            emailLoginVc.delegate = self
            
            let nav = UINavigationController(rootViewController: emailLoginVc)
            
            // Show Login
            present(nav, animated: true, completion: nil)
        }
    }

    func continueAsGuest()
    {
        AppStateTransitioner.transitionToMainStoryboard(true)
    }
    
    // MARK: Authentication Delegate
    func userDidCancelAuthentication()
    {
        enableButtons()
    }
    
    func authenticationDidSucceed()
    {
        print("Authentication Succeeded")
    }
    
    // MARK: Handle UI Interactivity
    
    func disableButttons()
    {
        facebookButton.isUserInteractionEnabled = false
        signUpButton.isUserInteractionEnabled = false
        loginButton.isUserInteractionEnabled = false
        tryItLabel.isUserInteractionEnabled = false
    }
    
    func enableButtons()
    {
        facebookButton.isUserInteractionEnabled = true
        signUpButton.isUserInteractionEnabled = true
        loginButton.isUserInteractionEnabled = true
        tryItLabel.isUserInteractionEnabled = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
