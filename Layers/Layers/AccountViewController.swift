//
//  AccountViewController.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

import FBSDKLoginKit
import ObjectMapper
import MBProgressHUD

private enum TableSection: Int
{
    case Contact = 0, Legal, AccountState, Count
}

private enum LegalTableRow: Int
{
    case Terms = 0, Privacy, OpenSource
}

class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AuthenticationDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ctaView: UIView!
    
    @IBOutlet weak var ctaLabel: UILabel!
    
    @IBOutlet weak var ctaXButton: UIButton!
    
    var shouldShowCTA: Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "Account".uppercaseString
        
        tabBarItem.title = "account".uppercaseString
        tabBarItem.image = UIImage(named: "person")
        tabBarItem.image = UIImage(named: "person-filled")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        tableView.backgroundColor = Color.BackgroundGrayColor
        
        tableView.estimatedRowHeight = 44.0
        
        hideCTAIfNeeded(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.contentOffset = CGPointMake(0, 0)
    }
    
    func configureCTA()
    {
        let regularAttributes = [NSForegroundColorAttributeName: Color.whiteColor(),
                                 NSFontAttributeName: Font.OxygenRegular(size: 16.0),
                                 ]
        let boldAttributes = [NSForegroundColorAttributeName: Color.whiteColor(),
                              NSFontAttributeName: Font.OxygenBold(size: 16.0),
                              ]
        
        let mutableString = NSMutableAttributedString()
        
        mutableString.appendAttributedString(NSAttributedString(string: "Create a free account", attributes: boldAttributes))
        
        mutableString.appendAttributedString(NSAttributedString(string: " or ", attributes: regularAttributes))
        
        mutableString.appendAttributedString(NSAttributedString(string: "sign in", attributes: boldAttributes))
        
        mutableString.appendAttributedString(NSAttributedString(string: " to get access to sale alerts.", attributes: regularAttributes))
        
        ctaLabel.attributedText = mutableString
        
        ctaView.backgroundColor = Color.NeonBlueColor
        
        ctaView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showAccountActionSheet)))
        
        ctaXButton.addTarget(self, action: #selector(hideCTA), forControlEvents: .TouchUpInside)
    }
    
    // MARK: Sign Up
    func connectWithFacebook()
    {
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
                
                LRSessionManager.sharedManager.registerWithFacebook( { (success, error, result) -> Void in
                    
                    if success
                    {
                        log.debug("Facebook Registration Integration Complete.")
                        
                        // Show Confirmation Screen
                        let loginStoryboard = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
                        if let confirmFacebookVc = loginStoryboard.instantiateViewControllerWithIdentifier("ConfirmFacebookInfoViewController") as? ConfirmFacebookInfoViewController
                        {
                            if let facebookResponse = result as? FacebookUserResponse
                            {
                                confirmFacebookVc.isModal = true
                                
                                confirmFacebookVc.delegate = self
                                
                                confirmFacebookVc.facebookResponse = facebookResponse
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                self.presentViewController(confirmFacebookVc, animated: true, completion: nil)
                                
                            })
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
    
    func signUp()
    {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
        
        if let createAccountVc = loginStoryboard.instantiateViewControllerWithIdentifier("EmailCreateAccountViewController") as? EmailCreateAccountViewController
        {
            createAccountVc.delegate = self
            
            let nav = UINavigationController(rootViewController: createAccountVc)
            
            presentViewController(nav, animated: true, completion: nil)
        }
    }
    
    func signIn()
    {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
        
        if let loginVc = loginStoryboard.instantiateViewControllerWithIdentifier("EmailLoginViewController") as? EmailLoginViewController
        {
            loginVc.delegate = self
            
            let nav = UINavigationController(rootViewController: loginVc)
            
            presentViewController(nav, animated: true, completion: nil)
        }
    }
    
    func showAccountActionSheet()
    {
        FBSDKAppEvents.logEvent("Show Account Registration Options")

        // Show Create Account Action Sheet
        let accountActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // Connect With Facebook
        accountActionSheet.addAction((UIAlertAction(title: "Connect With Facebook", style: .Default, handler: { (action) -> Void in
            
            self.connectWithFacebook()
            
        })))
        
        // Create Account
        accountActionSheet.addAction((UIAlertAction(title: "Create Account", style: .Default, handler: { (action) -> Void in
            
            self.signUp()
            
        })))
        
        // Sign In
        accountActionSheet.addAction((UIAlertAction(title: "Sign In", style: .Default, handler: { (action) -> Void in
            
            self.signIn()
            
        })))
        
        // Cancel
        accountActionSheet.addAction((UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)))
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.presentViewController(accountActionSheet, animated: true, completion: nil)
        })
    }
    
    // MARK: Actions
    func hideCTAIfNeeded(animated: Bool)
    {
        if LRSessionManager.sharedManager.isAuthenticated() || !shouldShowCTA
        {
            if animated
            {
                self.tableViewTopConstraint.constant = 0

                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                        self.view.layoutIfNeeded()

                    }, completion: { (finished) -> Void in
                        
                        if self.ctaView != nil
                        {
                            self.ctaView.removeFromSuperview()
                        }
                })
            }
            else
            {
                // Not animated
                self.tableViewTopConstraint.constant = 0
                
                if self.ctaView != nil
                {
                    self.ctaView.removeFromSuperview()
                }
            }
            
            return
        }
        
        // If CTA won't be hidden, configure it
        configureCTA()
    }
    
    func hideCTA()
    {
        FBSDKAppEvents.logEvent("User Hides Account CTA Taps")

        shouldShowCTA = false
        
        self.hideCTAIfNeeded(true)
    }
    
    // MARK: Create Account Delegate
    func authenticationDidSucceed()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in

            self.hideCTAIfNeeded(false)
        
            self.tableView.reloadData()
            
        })
    }
    
    // MARK: Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return TableSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection
            {
                
            case .Contact:
                return 1
                
            case .Legal:
                return 3
                
            case .AccountState:
                return 1
                
            default:
                return 0
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell")!
        
        if let tableSection: TableSection = TableSection(rawValue: indexPath.section)
        {
            switch tableSection
            {
                
            case .Contact:
                
                cell.textLabel!.text = "Contact Us"
                cell.accessoryType = .DisclosureIndicator
                
            case .Legal:
                
                if let legalRow: LegalTableRow = LegalTableRow(rawValue: indexPath.row)
                {
                    switch legalRow {
                    case .Terms:
                        
                        cell.textLabel!.text = "Terms of Service"
                        cell.accessoryType = .DisclosureIndicator
                        
                    case .Privacy:
                        
                        cell.textLabel!.text = "Privacy Policy"
                        cell.accessoryType = .DisclosureIndicator
                        
                    case .OpenSource:
                        
                        cell.textLabel!.text = "Open Source Attribution"
                        cell.accessoryType = .DisclosureIndicator
                    }
                }
                
            case .AccountState:
                
                if indexPath.row == 0
                {
                    if LRSessionManager.sharedManager.isAuthenticated()
                    {
                        // Already Logged in
                        cell.textLabel?.text = "Sign Out"
                        cell.textLabel?.textAlignment = .Center
                        cell.textLabel?.textColor = Color.RedColor
                    }
                    else
                    {
                        // Not logged in
                        cell.textLabel?.text = "Sign In"
                        cell.textLabel?.textAlignment = .Center
                        cell.textLabel?.textColor = Color.DarkNavyColor
                    }
                }
            
            default:
                return cell
                
            }
        }
        
        return cell
    }
    
    // MARK: Table View Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let tableSection: TableSection = TableSection(rawValue: indexPath.section)
        {
            switch tableSection
            {
                
            case .Contact:
                
                //Show Contact Page
                FBSDKAppEvents.logEvent("Contact Us Button Taps")
                
                performSegueWithIdentifier("ShowContactUsViewController", sender: self)
                
            case .Legal:
                
                if let legalRow: LegalTableRow = LegalTableRow(rawValue: indexPath.row)
                {
                    switch legalRow {
                    case .Terms:
                        
                        //Show Terms
                        performSegueWithIdentifier("ShowSimpleWebViewController", sender: indexPath)
                        
                    case .Privacy:
                        
                        // Show Privacy
                        performSegueWithIdentifier("ShowSimpleWebViewController", sender: indexPath)
                        
                    case .OpenSource:
                        
                        //Show Open Source
                        performSegueWithIdentifier("ShowOpenSourceViewController", sender: indexPath)
                    }
                }
                
            case .AccountState:
                
                if indexPath.row == 0
                {
                    if !LRSessionManager.sharedManager.isAuthenticated()
                    {
                        showAccountActionSheet()
                    }
                    else
                    {
                        //Clear Credentials
                        LRSessionManager.sharedManager.logout()
                        
                        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
                        hud.mode = .CustomView
                        hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                        
                        hud.labelText = "Successfully Logged Out"
                        hud.labelFont = Font.OxygenBold(size: 17.0)
                        hud.hide(true, afterDelay: 1.5)
                        
                        tableView.reloadData()
                    }
                }
                 
            default:
                log.debug("didSelectRowAtIndexPath Error")
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        return 48.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection
            {
                
            case .Contact:
                
                return 24.0
                
            case .Legal:
                return 23.0
                
            case .AccountState:
                return 23.0
                
            default:
                return 1.0
            }
        }
        
        return 1.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if TableSection(rawValue: section) == .AccountState
        {
            return 24.0
        }
        
        return 1.0
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in

                    cell.backgroundColor = Color.HighlightedGrayColor
                
                }, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                
                    cell.backgroundColor = Color.whiteColor()
                
                }, completion: nil)
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowSimpleWebViewController"
        {
            var webUrlString: String?
            
            var vcTitle: String?
            
            if let indexPath = sender as? NSIndexPath
            {
                if let legalTableRow: LegalTableRow = LegalTableRow(rawValue: indexPath.row)
                {
                    switch legalTableRow {
                    case .Terms:
                        
                        vcTitle = "Terms & Conditions"
                        webUrlString = "https://www.google.com/?gfe_rd=ssl"
                        
                    case .Privacy:
                        
                        vcTitle = "Privacy Policy"
                        webUrlString = "http://trylayers.com/privacy-policy/"
                        
                    case .OpenSource:
                        
                        vcTitle = "Open Source Libraries"
                        webUrlString = "https://www.google.com/?gfe_rd=ssl"
                    }
                }
            }
            //Currently sends the same url for everything
            if let destinationVC = segue.destinationViewController as? SimpleWebViewController
            {
                if let urlString = webUrlString
                {
                    destinationVC.webURL = NSURL(string: urlString)
                }
                
                if let viewControllerTitle = vcTitle
                {
                    destinationVC.title = viewControllerTitle
                }
            }
        }
    }
    
    
}