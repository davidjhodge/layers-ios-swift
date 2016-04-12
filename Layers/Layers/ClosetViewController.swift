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
        
        title = "LAYERS".uppercaseString
        
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
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: ClosetCell = tableView.dequeueReusableCellWithIdentifier("ClosetCell") as! ClosetCell
        
        cell.selectionStyle = .None
        
        cell.brandLabel.text = "Polo Ralph Lauren".uppercaseString
        
        cell.productLabel.text = "Big Pony Polo"
        
        cell.variantLabel.text = "Navy Blue"
        
        return cell
    }
    
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
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0
        {
            return "Shirts".uppercaseString
        }
        
        return ""
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 132.0
    }
    
}