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
        // If Success
        view.endEditing(true)
        
        navigationController?.popViewControllerAnimated(true)
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
        
//        if section == TableSection.Name.rawValue
//        {
//            return 0.01
//        }
//        else
//        {
            return 8
//        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    // MARK: Table View Delegate
    
    
}