//
//  ClosetViewController.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class ClosetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "My Closet".uppercaseString
        
        tabBarItem.title = "my closet".uppercaseString
        tabBarItem.image = UIImage(named: "coathanger")
        tabBarItem.image = UIImage(named: "coathanger-filled")
    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        navigationController?.navigationBar.translucent = false
//    }
    
    // MARK: Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Accounts for seperators
        var rowCount = 5
        
        if rowCount == 0
        {
            return rowCount
        }
        else
        {
            rowCount = rowCount * 2 - 1
        }
        
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == false
        {
            let cell: ClosetCell = tableView.dequeueReusableCellWithIdentifier("ClosetCell") as! ClosetCell
            
            cell.selectionStyle = .None
            
            cell.brandLabel.text = "Polo Ralph Lauren".uppercaseString
            
            cell.productLabel.text = "Big Pony Polo"
            
            cell.variantLabel.text = "Navy Blue"
            
            return cell
        }
        else
        {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SeperatorCell")!
            
            return cell
        }

    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//        cell.contentView.backgroundColor = Color.BackgroundGrayColor
//        
//        //132 is hardcoded
//        let backgroundView : UIView = UIView(frame: CGRectMake(0, 8, self.view.frame.size.width, 132 + 8))
//        
//        backgroundView.layer.backgroundColor = Color.whiteColor().CGColor
//        backgroundView.layer.masksToBounds = false
//        
//        cell.contentView.addSubview(backgroundView)
//        cell.contentView.sendSubviewToBack(backgroundView)
//    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.backgroundColor = Color.clearColor()
        header.textLabel?.font = Font.CharterBold(size: 16.0)
        header.textLabel?.textColor = Color.DarkTextColor
    }
    
    // MARK: Table View Delegate
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 48.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0
        {
            return "Shirts".uppercaseString
        }
        
        return ""
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row % 2 == false
        {
            // Normal Cell
            return 132.0
        }
        else
        {
            // Seperator Cell
            return 8.0
        }
    }
    
}