//
//  TextFilterViewController.swift
//  Layers
//
//  Created by David Hodge on 5/11/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

struct FilterItem
{
    var itemText: String?
    
    var isSelected: Bool = false
}

class TextFilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var filterType: FilterType?
    
    var items: Array<FilterItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        // Set the Navigation Title
        setNavTitle()
        
        setFilterItems()
    }
    
    // MARK: Initialization Helper Methods
    
    func setNavTitle()
    {
        if let type = filterType
        {
            switch type {
            case .Category:
                
                title = "Category".uppercaseString
                
            case .Brand:
                
                title = "Brand".uppercaseString
                
            case .Retailer:
                
                title = "Retailer".uppercaseString

            case .Price:
                
                title = "Price".uppercaseString
                
            default:
                title = ""
            }
        }
    }
    
    func setFilterItems()
    {
        // TEMP. Instead we should import the categories, retailers, etc from the network
        var item1 = FilterItem()
        item1.itemText = "Ralph Lauren"
        
        var item2 = FilterItem()
        item2.itemText = "J. Crew"
        
        var item3 = FilterItem()
        item3.itemText = "Gucci"
        
        var item4 = FilterItem()
        item4.itemText = "Mane"
        
        items = [item1, item2, item3, item4]
        
//        if let type = filterType
//        {
//            switch type {
//            case .Category:
//                
//                LRSessionManager.sharedManager.loadItemsForFilter
//                
//            case .Brand:
//                
//
//                
//            case .Retailer:
//                
//
//
//            default:
//                break
//            }
//        }
    }
    
    // MARK: Add/Remove Actions
    func addSelection(index: Int)
    {
        if let filterItems = items
        {            
            if filterItems[safe: index] != nil
            {
                items![index].isSelected = true
                
                updateRowAtIndex(index)
            }
        }
    }
    
    func deleteSelection(index: Int)
    {
        if let filterItems = items
        {
            if filterItems[safe: index] != nil
            {
                items![index].isSelected = false
                
                updateRowAtIndex(index)
            }
        }
    }
    
    func updateRowAtIndex(index: Int)
    {
        tableView.beginUpdates()
        
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
        
        tableView.endUpdates()
    }
    
    // MARK: Price Slider Action
    func sliderValueChanged(sender: UISlider)
    {
        print(sender.value)
    }
    
    // MARK: UITableView Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let type = filterType
        {
            if type == FilterType.Price
            {
                return 1
            }
            else
            {
                if let filterItems = items
                {
                    return filterItems.count
                }
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let type = filterType
        {
            if type == FilterType.Price
            {
                // Price
                let priceCell: SliderCell = tableView.dequeueReusableCellWithIdentifier("SliderCell") as! SliderCell
                
                priceCell.minLabel.text = "$0"
                
                priceCell.maxLabel.text = "$100"
                
//                priceCell.slider.addTarget(self, action: #selector(sliderValueChanged(_:)), forControlEvents: .ValueChanged)
                
                //To identify the slider when value changes
                priceCell.slider.tag = indexPath.row
                
                priceCell.selectionStyle = .None
                
                return priceCell
            }
            else
            {
                // Category, Brand, Retailer
                let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("CheckmarkCell")!
                
                cell.textLabel?.font = Font.OxygenRegular(size: 14.0)
                
                cell.selectionStyle = .None
                
                if let filterItems = items
                {
                    if let item: FilterItem = filterItems[indexPath.row]
                    {
                        if let itemText = item.itemText
                        {
                            cell.textLabel?.text = itemText
                        }
                        
                        if item.isSelected
                        {
                            cell.accessoryType = .Checkmark
                        }
                        else
                        {
                            cell.accessoryType = .None
                        }
                    }
                }
                
                return cell
            }
        }
        else
        {
            return UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
        }
    }
    
    // MARK: UITableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let filterItems = items
        {
            if let selectedItem = filterItems[safe: indexPath.row]
            {
                if selectedItem.isSelected
                {
                    // Item is already selected. Clear the selection
                    deleteSelection(indexPath.row)
                }
                else
                {
                    // Select the item
                    addSelection(indexPath.row)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let type = filterType
        {
            if type == FilterType.Price
            {
                return 64.0
            }
            else
            {
                return 44.0
            }
        }
        
        return 44.0
    }
}