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
        facebookButton.addTarget(self, action: #selector(connectWithFacebook), forControlEvents: .TouchUpInside)
        
        signUpButton.addTarget(self, action: #selector(signUp), forControlEvents: .TouchUpInside)
        
        loginButton.addTarget(self, action: #selector(login), forControlEvents: .TouchUpInside)

        configureAppearance()
    }

    func configureAppearance()
    {
        // Logo
        layersLabel.attributedText = NSAttributedString(string: "layers".uppercaseString, attributes: [NSForegroundColorAttributeName: Color.PrimaryAppColor,
            NSFontAttributeName: Font.PrimaryFontRegular(size: 30.0),
            NSKernAttributeName: 4.5
            ])
        
        // Headline
        let headline = "Men's clothing," + "\n" + "curated by the community"
        
        headlineLabel.attributedText = NSAttributedString(string: headline, attributes: [NSForegroundColorAttributeName: Color.GrayColor,
            NSFontAttributeName: Font.PrimaryFontLight(size: 16.0),
            NSKernAttributeName: 0.9])
        
        // Connect with Facebook
        facebookButton.setAttributedTitle(NSAttributedString(string: "Connect with Facebook".uppercaseString, attributes: FontAttributes.filledButtonAttributes), forState: .Normal)
        
        facebookButton.setBackgroundColor(Color.PrimaryAppColor, forState: .Normal)
        facebookButton.setBackgroundColor(Color.HighlightedPrimaryAppColor, forState: .Highlighted)
        facebookButton.layer.cornerRadius = 4.0
        facebookButton.clipsToBounds = true
        
        // Sign Up Button
        signUpButton.setBackgroundColor(Color.whiteColor(), forState: .Normal)
        signUpButton.setBackgroundColor(Color.PrimaryAppColor, forState: .Highlighted)
        
        signUpButton.setAttributedTitle(NSAttributedString(string: "Sign Up".uppercaseString, attributes: FontAttributes.buttonAttributes), forState: .Normal)
        signUpButton.setAttributedTitle(NSAttributedString(string: "Sign Up".uppercaseString, attributes: FontAttributes.filledButtonAttributes), forState: .Highlighted)
        
        signUpButton.layer.cornerRadius = 4.0
        signUpButton.clipsToBounds = true
        signUpButton.layer.borderWidth = 1.0
        signUpButton.layer.borderColor = Color.PrimaryAppColor.CGColor
        
        // Login Button
        loginButton.setBackgroundColor(Color.whiteColor(), forState: .Normal)
        loginButton.setBackgroundColor(Color.PrimaryAppColor, forState: .Highlighted)
        
        loginButton.setAttributedTitle(NSAttributedString(string: "Login".uppercaseString, attributes: FontAttributes.buttonAttributes), forState: .Normal)
        loginButton.setAttributedTitle(NSAttributedString(string: "Login".uppercaseString, attributes: FontAttributes.filledButtonAttributes), forState: .Highlighted)

        loginButton.layer.cornerRadius = 4.0
        loginButton.clipsToBounds = true
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = Color.PrimaryAppColor.CGColor
        
        // Try it Label
        tryItLabel.attributedText = tryItLabelAttributedString()
        
        tryItLabel.linkAttributeDefault = [NSForegroundColorAttributeName: Color.PrimaryAppColor,
                                           NSFontAttributeName: Font.PrimaryFontSemiBold(size: 14.0),
                                           NSKernAttributeName: 2.0]
        
        tryItLabel.linkAttributeHighlight = [NSForegroundColorAttributeName: Color.HighlightedPrimaryAppColor,
                                           NSFontAttributeName: Font.PrimaryFontSemiBold(size: 14.0),
                                           NSKernAttributeName: 2.0]
        
        tryItLabel.setLinkForSubstring("Try it first", withLinkHandler: { (hyperLabel: FRHyperLabel!, substring: String!) -> Void in
         
            self.continueAsGuest()
        })
    }
    
    func tryItLabelAttributedString() -> NSAttributedString
    {
        let string = NSMutableAttributedString()
        
        string.appendAttributedString(NSAttributedString(string: "Not quite ready? ", attributes: [
            NSForegroundColorAttributeName: Color.GrayColor,
            NSFontAttributeName: Font.PrimaryFontLight(size: 14.0),
            NSKernAttributeName: 2.0
            ]))
        
        string.appendAttributedString(NSAttributedString(string: "Try it first", attributes: [
            NSForegroundColorAttributeName: Color.PrimaryAppColor,
            NSFontAttributeName: Font.PrimaryFontSemiBold(size: 14.0),
            NSKernAttributeName: 2.0
            ]))
        
        return NSAttributedString(attributedString: string)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: Actions
    
    func connectWithFacebook()
    {
        print("Connected with Facebook")
    }
    
    func signUp()
    {
        FBSDKAppEvents.logEvent("Login - Sign Up Button Taps")
        
        disableButttons()
        
        // Show Email Create Account View Controller
        let loginStoryboard = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
        
        if let emailSignUpVc = loginStoryboard.instantiateViewControllerWithIdentifier("EmailCreateAccountViewController") as? EmailCreateAccountViewController
        {
            emailSignUpVc.delegate = self
            
            let nav = UINavigationController(rootViewController: emailSignUpVc)
            
            presentViewController(nav, animated: true, completion: nil)
        }
        
    }
    
    func login()
    {
        FBSDKAppEvents.logEvent("Login - Login Button Taps")
        
        disableButttons()
        
        // Show Email Login View Controller
        let loginStoryboard = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
        
        if let emailLoginVc = loginStoryboard.instantiateViewControllerWithIdentifier("EmailLoginViewController") as? EmailLoginViewController
        {
            emailLoginVc.delegate = self
            
            let nav = UINavigationController(rootViewController: emailLoginVc)
            
            // Show Login
            presentViewController(nav, animated: true, completion: nil)
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
        facebookButton.userInteractionEnabled = false
        signUpButton.userInteractionEnabled = false
        loginButton.userInteractionEnabled = false
        tryItLabel.userInteractionEnabled = false
    }
    
    func enableButtons()
    {
        facebookButton.userInteractionEnabled = true
        signUpButton.userInteractionEnabled = true
        loginButton.userInteractionEnabled = true
        tryItLabel.userInteractionEnabled = true
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
