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
    case Contact = 0, Legal, Logout, Count
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
    func signUp()
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
                
                //                let fbAccessToken = result.token.tokenString
                
                // Facebook token now exists and can be accessed at FBSDKAccessToken.currentAccessToken()
                LRSessionManager.sharedManager.registerWithFacebook( { (success, error, result) -> Void in
                    
                    if success
                    {
                        log.debug("Facebook Registration Integration Complete.")
                        
                        let credential = LRSessionManager.sharedManager.credentialsProvider.identityId
                        
                        print(credential)
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
                
            case .Logout:
                return 1 + 1
                
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
                
            case .Logout:
                
                if indexPath.row == 0
                {
                    cell.textLabel?.text = "Sign Up"
                    cell.textLabel?.textAlignment = .Center
                    cell.textLabel?.textColor = Color.DarkNavyColor
                }
                else
                {
                    cell.textLabel!.text = "Log out"
                    cell.textLabel?.textAlignment = .Center
                    cell.textLabel?.textColor = Color.RedColor
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
                
            case .Logout:
                
                if indexPath.row == 0
                {
                    signUp()
                }
                else
                {
                    //Clear Credentials
                    LRSessionManager.sharedManager.logout()
                    
                    AppStateTransitioner.transitionToLoginStoryboard(true)
                }
                 
            default:
                log.debug("didSelectRowAtIndexPath Error")
            }
        }
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
                
            case .Logout:
                return 23.0
                
            default:
                return 1.0
            }
        }
        
        return 1.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
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