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

protocol FilterDelegate {
    
    func didUpdateFilter()
}

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FilterTypeDelegate
{
    var delegate: FilterDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var applyButton: UIButton!
    
    // Get current filter, which is a default Filter object if no filter has been set
    var newFilter = FilterManager.defaultManager.getCurrentFilter()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "Filter".uppercaseString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".uppercaseString, style: .Plain, target: self, action: #selector(cancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset".uppercaseString, style: .Plain, target: self, action: #selector(reset))
        
        applyButton.addTarget(self, action: #selector(applyFilter), forControlEvents: .TouchUpInside)
    }
    
    // MARK: Actions
    func cancel()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reset()
    {
        // Clear filter
        newFilter = Filter()
        
        tableView.reloadData()
    }
    
    func applyFilter()
    {
        FilterManager.defaultManager.setNewFilter(newFilter)
        
        delegate?.didUpdateFilter()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Range Slider
    func sliderValueChanged(sender: UISlider)
    {

    }
    
    // MARK: FilterTypeDelegate
    func textFilterChanged(filters: Array<FilterObject>?, filterType: FilterType?)
    {
        if let newFilters = filters
        {
            if let type = filterType
            {
                switch type {
                case .Category:
                    
                    newFilter.categories = newFilters
                    
                case .Brand:
                    
                    newFilter.brands = newFilters
                    
                case .Retailer:
                    
                    newFilter.retailers.selections = newFilters
                    
                default:
                    break
                }
            }
            
            // Would be better practice to only reload the cell we updated
            tableView.reloadData()
        }
    }
    
    func sliderFilterChanged(filter: (minValue: Int, maxValue: Int)?, filterType: FilterType?)
    {
        if let sliderFilter = filter
        {
            if sliderFilter.minValue > 0 && sliderFilter.maxValue > 0
            {
                if filterType == .Price
                {
                    newFilter.priceRange = (minPrice: sliderFilter.minValue, maxPrice: sliderFilter.maxValue)
                }
            }
        }
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
                
                // If filter selected, show blue dot
                if newFilter.categories != nil
                {
                    cell.selectedCircleView.hidden = false
                }
                else
                {
                    cell.selectedCircleView.hidden = true
                }
                
            case .Brand:
                
                cell.filterTypeLabel.text = "Brand".uppercaseString
                
                // If J. Crew Filter Selected
                cell.filterSelectionLabel.text = "J. Crew"
                
                // If filter selected, show blue dot
                if newFilter.brands != nil
                {
                    cell.selectedCircleView.hidden = false
                }
                else
                {
                    cell.selectedCircleView.hidden = true
                }
                
            case .Retailer:
                
                cell.filterTypeLabel.text = "Retailer".uppercaseString
                
                cell.filterSelectionLabel.text = "Many Retailers"

                // If filter selected, show blue dot
                if newFilter.retailers.selections != nil
                {
                    cell.selectedCircleView.hidden = false
                }
                else
                {
                    cell.selectedCircleView.hidden = true
                }
                
            case .Price:
                
                cell.filterTypeLabel.text = "Price".uppercaseString

                cell.filterSelectionLabel.text = "25 - 50"
                
                // If filter selected, show blue dot
                if newFilter.priceRange != nil
                {
                    cell.selectedCircleView.hidden = false
                }
                else
                {
                    cell.selectedCircleView.hidden = true
                }
            
            case .Color:
                
                cell.filterTypeLabel.text = "Color".uppercaseString
                
                // Dynamically assign selected color from stored colorName:UIColor Dict
                cell.filterSelectionLabel.text = "Red"
                
                cell.filterSelectionLabel.textColor = Color.RedColor
                
                // If filter selected, show blue dot
                if newFilter.color != nil
                {
                    cell.selectedCircleView.hidden = false
                }
                else
                {
                    cell.selectedCircleView.hidden = true
                }
                
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
                        destinationVc.filterTypeDelegate = self

                        switch type {
                        case .Category:
                            
                            if let currentFilters = newFilter.categories
                            {
                                var array = Array<FilterObject>()
                                
                                for currFilter in currentFilters
                                {
                                    array.append(currFilter)
                                }
                                
                                destinationVc.selectedItems = array
                            }
                            
                        case .Brand:
                            
                            if let currentFilters = newFilter.brands
                            {
                                var array = Array<FilterObject>()
                                
                                for currFilter in currentFilters
                                {
                                    array.append(currFilter)
                                }
                                
                                destinationVc.selectedItems = array
                            }
                            
                        case .Retailer:
                            
                            if let currentFilters = newFilter.retailers.selections
                            {
                                var array = Array<FilterObject>()
                                
                                for currFilter in currentFilters
                                {
                                    array.append(currFilter)
                                }
                                
                                destinationVc.selectedItems = array
                            }
                            
                        default:
                            break
                        }
                    }
                }
            }
        }
//        else if segue.identifier == "ShowSliderFilterViewController"
//        {
//            
//        }
        else if segue.identifier == "ShowColorFilterViewController"
        {
            if let destinationVc = segue.destinationViewController as? ColorFilterViewController
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
    }
}