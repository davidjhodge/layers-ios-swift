//
//  FilterViewController.swift
//  Layers
//
//  Created by David Hodge on 4/19/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import NMRangeSlider

enum FilterType: Int
{
    case Category = 0, Brand, Retailer, Price, Color, Count
}

protocol FitlerDelegate {
    
    func didUpdateFilter()
}

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var delegate: FitlerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "Filter".uppercaseString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".uppercaseString, style: .Plain, target: self, action: #selector(cancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".uppercaseString, style: .Done, target: self, action: #selector(done))
    }
    
    // MARK: Actions
    func cancel()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func done()
    {
        delegate?.didUpdateFilter()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Range Slider
    func sliderValueChanged(sender: UISlider)
    {

    }
    
    // MARK: Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FilterType.Count.rawValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SubtitleFilterCell") as! SubtitleFilterCell
        
        cell.accessoryType = .DisclosureIndicator
        
        cell.filterTypeLabel.text = ""
        cell.filterSelectionLabel.text = ""
        cell.selectedCircleView.hidden = true

        if let filterType = FilterType(rawValue: indexPath.row)
        {
            switch filterType {
                
            case .Category:

                cell.filterTypeLabel.text = "Category".uppercaseString
                
                cell.filterSelectionLabel.text = "T-Shirts"
                
            case .Brand:
                
                cell.filterTypeLabel.text = "Brand".uppercaseString
                
                // If J. Crew Filter Selected
                cell.filterSelectionLabel.text = "J. Crew"
                
                cell.selectedCircleView.hidden = false

            case .Retailer:
                
                cell.filterTypeLabel.text = "Retailer".uppercaseString
                
                cell.filterSelectionLabel.text = "Many Retailers"

            case .Price:
                
                cell.filterTypeLabel.text = "Price".uppercaseString

                cell.filterSelectionLabel.text = "25 - 50"
                
            
            case .Color:
                
                cell.filterTypeLabel.text = "Color".uppercaseString
                
                // Dynamically assign selected color from stored colorName:UIColor Dict
                cell.filterSelectionLabel.text = "Red"
                
                cell.filterSelectionLabel.textColor = Color.RedColor
                
            default:
                return cell
            }
        }
        
        return cell
    }
    
    // MARK: Table View Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let filterType = FilterType(rawValue: indexPath.row)
        {
            switch filterType {
 
            case .Category:
                // Use the logic for .Price
                fallthrough
                
            case .Brand:
                // Use the logic for .Price
                fallthrough
                
            case .Retailer:
                // Use the logic for .Price
                fallthrough
                
            case .Price:
                
                performSegueWithIdentifier("ShowTextFilterViewController", sender:filterType.rawValue)
                
            case .Color:

                performSegueWithIdentifier("ShowColorFilterViewController", sender:filterType.rawValue)

                break
                
            default:
                break
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 64.0
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowTextFilterViewController"
        {
            if let destinationVc = segue.destinationViewController as? TextFilterViewController
            {
                if let senderRawValue = sender as? Int
                {
                    if let type = FilterType(rawValue: senderRawValue)
                    {
                        destinationVc.filterType = type
                    }
                }
            }
        }
//        else if segue.identifier == "ShowSliderFilterViewController"
//        {
//            
//        }
//        else if segue.identifier == "ShowColorFilterViewController"
//        {
//            
//        }
    }
}