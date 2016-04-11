//
//  EmailLoginViewController.swift
//  Layers
//
//  Created by David Hodge on 4/11/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class EmailLoginViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var loginButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "login".uppercaseString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: #selector(login), forControlEvents: .TouchUpInside)
    }
    
    // MARK: Actions
    func login()
    {
        AppStateTransitioner.transitionToMainStoryboard(true)
    }
    
    // MARK: Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TextFieldCell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as! TextFieldCell
        
        cell.textField.textColor = Color.DarkTextColor
        
        //Email
        if indexPath.row == 0
        {
            cell.textField.placeholder = "Email"
        }
        //Password
        else if indexPath.row == 1
        {
            cell.textField.placeholder = "Password"
            cell.textField.secureTextEntry = true
        }
        else
        {
            log.debug("cellForRowAtIndexPath Error")
        }
        
        return cell
    }
    
    // MARK: Table View Delegate
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0
        {
            return 0.01
        }
        else
        {
            return 24.0
        }
    }
}