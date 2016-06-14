//
//  ConfirmFacebookInfoViewController.swift
//  Layers
//
//  Created by David Hodge on 6/13/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

private enum TableRow: NSInteger
{
    case Name = 0, Email, GenderAge, Count
}

class ConfirmFacebookInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
         return TableRow.Count.rawValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let tableRow = TableRow(rawValue: indexPath.row)
        {
            if tableRow == .Name
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("TwoTextFieldCell") as! TwoTextFieldCell
                
                cell.firstTextField.placeholder = "First Name"
                
                cell.secondTextField.placeholder = "Last Name"

                return cell
            }
            else if tableRow == .Email
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as! TextFieldCell
                
                cell.textField.text = "Email"
                
                return cell
            }
            else if tableRow == .GenderAge
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("TwoTextFieldCell") as! TwoTextFieldCell
                
                cell.firstTextField.placeholder = "Gender"
                
                cell.secondTextField.placeholder = "Age"
                
                return cell
            }
        }
        
        return UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
    }
    
    // MARK: Table View Delegate
    
}