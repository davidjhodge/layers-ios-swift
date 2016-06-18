//
//  OpenSourceViewController.swift
//  Layers
//
//  Created by David Hodge on 6/18/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class OpenSourceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var openSourceLibraries = OpenSource.openSourceLibraries()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Open Source Libraries".uppercaseString
        
        tableView.tableFooterView = UIView()
        
        tableView.backgroundColor = Color.BackgroundGrayColor
    }
    // MARK: Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openSourceLibraries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("OpenSourceCell") as! OpenSourceCell
        
        cell.selectionStyle = .None
        
        if let library = openSourceLibraries[safe: indexPath.row]
        {
            if let name = library.name
            {
                cell.titleLabel.text = name
            }
            
            if let license = library.licenseDescription
            {
                cell.descriptionTextView.text = license
                
                cell.descriptionTextView.bounds.size.height = cell.descriptionTextView.contentSize.height
            }
        }
        
        return cell
    }
    
    // MARK: Table View Delegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 100.0
    }
}