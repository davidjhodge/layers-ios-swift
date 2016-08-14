//
//  ContactUsViewController.swift
//  Layers
//
//  Created by David Hodge on 4/17/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import UITextView_Placeholder
import MBProgressHUD

private enum TableSection: Int
{
    case Email, Description, Count
}

class ContactUsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "Contact Us"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send".uppercaseString, style: .Done, target: self, action: #selector(send))
        
        tableView.backgroundColor = Color.BackgroundGrayColor
        
//        tableView.separatorColor = Color(red: 237.0, green: 237.0, blue: 237.0, alpha: 1.0)
    }
    
    func send()
    {
        if let emailCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: TableSection.Email.rawValue)) as? TextFieldCell,
            let contentCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: TableSection.Description.rawValue)) as? TextViewCell
        {
            if let email = emailCell.textField.text,
                let content = contentCell.textView.text
            {
                if isValidEmail(email)
                {
                    LRSessionManager.sharedManager.submitContactForm(email, content: content, completionHandler: { (success, error, response) -> Void in
                        
                        if success
                        {
                            // Show success hud for 1.5 seconds. Hide it, end editing, and pop
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                                hud.mode = .CustomView
                                hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                                
                                hud.label.text = "Message Sent".uppercaseString
                                hud.label.font = Font.OxygenBold(size: 17.0)
                                hud.hideAnimated(true, afterDelay: 1.0)
                                
                                self.performSelector(#selector(self.done), withObject: nil, afterDelay: 1.0)
                            })
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

                    return
                }
                else
                {
                    // Invalid Email
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        let alert = UIAlertController(title: "ENTER_VALID_EMAIL".localized, message: nil, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                    
                    return
                }
            }
        }
        
        // Invalid parameters
        let alert = UIAlertController(title: "INVALID_PARAMETERS".localized, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func done()
    {
        self.view.endEditing(true)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.Count.rawValue

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TextFieldCell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as! TextFieldCell
        
        cell.selectionStyle = .None
        
        if let tableSection = TableSection(rawValue: indexPath.section)
        {
            switch tableSection {
                
            case .Email:
                
                cell.textField.placeholder = "Email"

            case.Description:
                
                let textViewCell: TextViewCell = tableView.dequeueReusableCellWithIdentifier("TextViewCell") as! TextViewCell
                
                textViewCell.textView.placeholder = "Description"
                
                textViewCell.selectionStyle = .None
                
                return textViewCell

            default:
                return cell
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == TableSection.Description.rawValue
        {
            return 128.0
        }
        else
        {
            return 48.0
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 8
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
}