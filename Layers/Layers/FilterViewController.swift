//
//  FilterViewController.swift
//  Layers
//
//  Created by David Hodge on 4/19/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

enum FilterType: Int
{
    case Category = 0, Brand, Retailer, Price, Color, Count
}

protocol FilterDelegate {
    
    func didUpdateFilter()
}

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FilterTypeDelegate, PriceFilterDelegate, ColorFilterDelegate
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
        
        tableView.backgroundColor = Color.BackgroundGrayColor
        
        applyButton.setBackgroundColor(Color.NeonBlueColor, forState: .Normal)
        applyButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .Highlighted)

        applyButton.addTarget(self, action: #selector(applyFilter), forControlEvents: .TouchUpInside)
        
        if !newFilter.hasActiveFilters()
        {
            applyButton.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if applyButton.hidden == false
        {
            if !newFilter.hasActiveFilters()
            {
                applyButton.hidden = true
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if applyButton.hidden == true
        {
            if newFilter.hasActiveFilters()
            {
                let transition: CATransition = CATransition()
                transition.duration = 0.2
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromLeft
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                applyButton.layer.addAnimation(transition, forKey: nil)
                
                applyButton.hidden = false
            }
        }
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
    
    // MARK: FilterTypeDelegate
    func textFilterChanged(filters: Array<FilterObject>?, filterType: FilterType?)
    {
        if let type = filterType
        {
            switch type {
            case .Category:
                
                newFilter.categories.selections = filters
                
            case .Brand:
                
                newFilter.brands.selections = filters
                
            case .Retailer:
                
                newFilter.retailers.selections = filters
                
            default:
                break
            }
            
            // Would be better practice to only reload the cell we updated
            tableView.reloadData()
        }
    }
    
    func priceFilterChanged(priceFilter: PriceFilter?) {
        
        if let priceFilter = priceFilter
        {
            if priceFilter.minPrice?.integerValue >= 0 && priceFilter.maxPrice?.integerValue > 0
            {
                newFilter.priceRange = priceFilter
                
                // Would be better practice to only reload the cell we updated
                tableView.reloadData()
            }
        }
        else
        {
            newFilter.priceRange = nil
            
            tableView.reloadData()
        }
    }

    // MARK: Color Filter Delegate
    func colorFilterChanged(colors: Array<ColorResponse>?) {
        
        newFilter.colors.selections = colors
        
        // Should reload just the color row to improve efficiency
        tableView.reloadData()
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
                
                if let categorySelections = newFilter.categories.selections
                {
                    if categorySelections.count == 1
                    {
                        if let firstCategoryName = categorySelections.first?.name
                        {
                            cell.filterSelectionLabel.text = firstCategoryName.capitalizedString
                        }
                    }
                    else
                    {
                        cell.filterSelectionLabel.text = "Multiple Categories"
                    }
                }
                else
                {
                    cell.filterSelectionLabel.text = "All Categories"
                }
                
                // If filter selected, show blue dot
                if newFilter.categories.selections != nil
                {
                    cell.selectedCircleView.hidden = false
                }
                else
                {
                    cell.selectedCircleView.hidden = true
                }
                
            case .Brand:
                
                cell.filterTypeLabel.text = "Brand".uppercaseString
                
                if let brandSelections = newFilter.brands.selections
                {
                    if brandSelections.count == 1
                    {
                        if let firstBrandName = brandSelections.first?.name
                        {
                            cell.filterSelectionLabel.text = firstBrandName.capitalizedString
                        }
                    }
                    else
                    {
                        cell.filterSelectionLabel.text = "Multiple Brands"
                    }
                }
                else
                {
                    cell.filterSelectionLabel.text = "All Brands"
                }
                
                // If filter selected, show blue dot
                if newFilter.brands.selections != nil
                {
                    cell.selectedCircleView.hidden = false
                }
                else
                {
                    cell.selectedCircleView.hidden = true
                }
                
            case .Retailer:
                
                cell.filterTypeLabel.text = "Retailer".uppercaseString
                
                if let retailerSelections = newFilter.retailers.selections
                {
                    if retailerSelections.count == 1
                    {
                        if let firstRetailerName = retailerSelections.first?.name
                        {
                            cell.filterSelectionLabel.text = firstRetailerName.capitalizedString
                        }
                    }
                    else
                    {
                        cell.filterSelectionLabel.text = "Many Retailers"
                    }
                }
                else
                {
                    cell.filterSelectionLabel.text = "All Retailers"
                }

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

                if let minPrice = newFilter.priceRange?.minPrice?.stringValue,
                    let maxPrice = newFilter.priceRange?.maxPrice?.stringValue
                {
                    cell.filterSelectionLabel.text = "\(minPrice) - \(maxPrice)"
                }
                else
                {
                    cell.filterSelectionLabel.text = "All Prices"
                }
                
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
                
                if let colorSelections = newFilter.colors.selections
                {
                    if colorSelections.count == 1
                    {
                        if let firstColorName = colorSelections.first?.colorName
                        {
                            cell.filterSelectionLabel.text = firstColorName.capitalizedString
                        }
                    }
                    else
                    {
                        cell.filterSelectionLabel.text = "Multiple Colors"
                    }
                }
                else
                {
                    cell.filterSelectionLabel.text = "All Colors"
                }
                
                // If filter selected, show blue dot
                if newFilter.colors.selections != nil
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
                // Use the logic for .Retailer
                fallthrough
                
            case .Brand:
                // Use the logic for .Retailer
                fallthrough
                
            case .Retailer:
                
                performSegueWithIdentifier("ShowTextFilterViewController", sender:filterType.rawValue)
                
            case .Price:
                
                performSegueWithIdentifier("ShowPriceFilterViewController", sender:filterType.rawValue)
                
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 24.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 24.0
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
                            
                            if let currentFilters = newFilter.categories.selections
                            {
                                var array = Array<FilterObject>()
                                
                                for currFilter in currentFilters
                                {
                                    array.append(currFilter)
                                }
                                
                                destinationVc.selectedItems = array
                            }
                            
                        case .Brand:
                            
                            if let currentFilters = newFilter.brands.selections
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
        else if segue.identifier == "ShowPriceFilterViewController"
        {
            if let destinationVc = segue.destinationViewController as? PriceFilterViewController
            {
                destinationVc.delegate = self
                
                if let currentFilter = newFilter.priceRange
                {
                    destinationVc.priceFilter = currentFilter
                }
            }
        }
        else if segue.identifier == "ShowColorFilterViewController"
        {
            if let destinationVc = segue.destinationViewController as? ColorFilterViewController
            {
                destinationVc.delegate = self
                
                if let currentFilters = newFilter.colors.selections
                {
                    var array = Array<ColorResponse>()
                    
                    for currFilter in currentFilters
                    {
                        array.append(currFilter)
                    }
                    
                    destinationVc.selectedColors = array
                }
            }
        }
    }
}