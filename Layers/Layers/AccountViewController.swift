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

private enum TableSection: Int
{
    case CallToAction = 0, Contact, Legal, AccountState, Count
}

private enum LegalTableRow: Int
{
    case Terms = 0, Privacy, OpenSource
}

class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
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
        LRSessionManager.sharedManager.register("dhodge416@gmail.com", password: "password123", completionHandler: { (success, error, response) -> Void in
            
            if success
            {
                // Signing up to user pool succeeded
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
    
    func signIn()
    {
        LRSessionManager.sharedManager.signIn("dhodge416@gmail.com", password: "password123", completionHandler: { (success, error, response) -> Void in
         
            if success
            {
                // Login to user pool succeeded
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
    
    func showAccountActionSheet()
    {
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
                
            case .CallToAction:
                
                // Show Call To Action if user is not logged in
                if !LRSessionManager.sharedManager.isAuthenticated()
                {
                    return 1
                }
                else
                {
                    return 0
                }
                
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
            case .CallToAction:
                
                if let cell: TextViewCell = tableView.dequeueReusableCellWithIdentifier("CallToActionCell") as? TextViewCell
                {
                    cell.selectionStyle = .None
                    
                    cell.textView.textColor = Color.whiteColor()
                    
                    // Attributed Text
                    
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

                    mutableString.appendAttributedString(NSAttributedString(string: " to get access to sale alerts. You'll never miss a sale again.", attributes: regularAttributes))

                    cell.textView.attributedText = NSAttributedString(attributedString: mutableString)
                    
                    return cell
                }
                
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
                    if !LRSessionManager.sharedManager.isAuthenticated()
                    {
                        // Not logged in
                        cell.textLabel?.text = "Sign In"
                        cell.textLabel?.textAlignment = .Center
                        cell.textLabel?.textColor = Color.DarkNavyColor
                    }
                    else
                    {
                        // Already Logged in
                        cell.textLabel?.text = "Sign Out"
                        cell.textLabel?.textAlignment = .Center
                        cell.textLabel?.textColor = Color.RedColor
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
                
            case .CallToAction:
                
                showAccountActionSheet()
                
            case .Contact:
                
                //Show Contact Page
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
                        performSegueWithIdentifier("ShowSimpleWebViewController", sender: indexPath)
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
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            AppStateTransitioner.transitionToLoginStoryboard(true)
                        })
                    }
                }
                 
            default:
                log.debug("didSelectRowAtIndexPath Error")
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if TableSection(rawValue: indexPath.section) == .CallToAction
        {
            return 96.0
        }

        return 48.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection
            {
            case .CallToAction:
                return 0.01
                
            case .Contact:
                
                if !LRSessionManager.sharedManager.isAuthenticated()
                {
                    return 0.01
                }
                
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
        
        if TableSection(rawValue: section) == .CallToAction
        {
            return 0.01
        }
        
        return 1.0
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
                        
                    default:
                        break
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