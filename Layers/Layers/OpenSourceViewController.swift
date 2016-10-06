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
        
        title = "Open Source Libraries"
        
        tableView.tableFooterView = UIView()
        
        tableView.backgroundColor = Color.BackgroundGrayColor
    }
    // MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openSourceLibraries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenSourceCell") as! OpenSourceCell
        
        cell.selectionStyle = .none
        
        if let library = openSourceLibraries[safe: (indexPath as NSIndexPath).row]
        {
            if let name = library.name
            {
                cell.titleLabel.attributedText = NSAttributedString(string: name, attributes: FontAttributes.headerTextAttributes)
            }
            
            if let license = library.licenseDescription
            {
                cell.descriptionTextView.attributedText = NSAttributedString(string: license, attributes: FontAttributes.darkBodyTextAttributes)
                
                cell.descriptionTextView.bounds.size.height = cell.descriptionTextView.contentSize.height
            }
        }
        
        return cell
    }
    
    // MARK: Table View Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100.0
    }
}
