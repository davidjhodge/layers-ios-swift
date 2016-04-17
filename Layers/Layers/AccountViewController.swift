//
//  AccountViewController.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

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
        
        title = "LAYERS".uppercaseString
        
        tabBarItem.title = "account".uppercaseString
        tabBarItem.image = UIImage(named: "person")
        tabBarItem.image = UIImage(named: "person-filled")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        tableView.backgroundColor = Color.BackgroundGrayColor
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
                
            case .Logout:
                
                cell.textLabel!.text = "Log out"
                cell.textLabel?.textAlignment = .Center
                cell.textLabel?.textColor = Color.RedColor
            
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
                        performSegueWithIdentifier("ShowSimpleWebViewController", sender: self)
                        
                    case .Privacy:
                        
                        // Show Privacy
                        performSegueWithIdentifier("ShowSimpleWebViewController", sender: self)
                        
                    case .OpenSource:
                        
                        //Show Open Source
                        performSegueWithIdentifier("ShowSimpleWebViewController", sender: self)
                    }
                }
                
            case .Logout:
                
                //Logout
                //Clear Credentials
                AppStateTransitioner.transitionToLoginStoryboard(true)
                
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
            //Currently sends the same url for everything
            if let destinationVC = segue.destinationViewController as? SimpleWebViewController
            {
                destinationVC.webURL = NSURL(string: "https://www.google.com/?gfe_rd=ssl")
            }
        }
    }
    
    
}