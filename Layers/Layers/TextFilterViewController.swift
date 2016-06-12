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

protocol FilterTypeDelegate
{
    func textFilterChanged(filters: Array<FilterObject>?, filterType: FilterType?)
}

class TextFilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var filterTypeDelegate: FilterTypeDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    var filterType: FilterType?
    
    var items: Array<FilterObject>?
    
    var selectedItems: Array<FilterObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        // Set the Navigation Title
        setNavTitle()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SELECT", style: .Plain, target: self, action:#selector(confirmSelection))
        
        reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let selections = selectedItems
        {
            var filterArray: Array<FilterObject>? = Array<FilterObject>()
            
            for selection in selections
            {
                var newFilter = FilterObject()
                
                if let filterText = selection.name
                {
                    newFilter.name = filterText
                }
                
                if let filterKey = selection.key
                {
                    newFilter.key = filterKey
                }
                
                if newFilter.name != nil && newFilter.key != nil
                {
                    filterArray!.append(newFilter)
                }
            }
            
            // Set the filter Array to nil if it has no contents.
            // This is done to maintain the correct filter state.
            if filterArray!.count == 0
            {
                filterArray = nil
            }
            
            // Pass filterArray to delegate
            if let delegate = filterTypeDelegate
            {
                if let type = filterType
                {
                    switch type {
                    case .Category:
                        
                        delegate.textFilterChanged(filterArray, filterType: FilterType.Category)
                        
                    case .Brand:
                        
                        delegate.textFilterChanged(filterArray, filterType: FilterType.Brand)
                        
                    case .Retailer:
                        
                        delegate.textFilterChanged(filterArray, filterType: FilterType.Retailer)
                        
                    default:
                        break
                    }
                }
            }
        }
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
                
            default:
                title = ""
            }
        }
    }
    
    func reloadData()
    {
        if let type = filterType
        {
            switch type {
            case .Category:
                
                FilterManager.defaultManager.fetchOriginalCategories( { (success, results) -> Void in
                    
                    if success
                    {
                        if let categories = results as? Array<CategoryResponse>
                        {
                            let parentCategories = categories.filter({ $0.parentId == 1 })
                            
                            let filterObjects = FilterObjectConverter.filterObjectArray(parentCategories)
                            
                            self.items = filterObjects
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.tableView.reloadData()
                            })
                        }
                    }
                })
                
            case .Brand:
                
                //Need to fetch brands
                FilterManager.defaultManager.fetchBrands( { (success, results) -> Void in
                    
                    if success
                    {
                        if let categories = results
                        {
                            self.items = categories
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.tableView.reloadData()
                            })
                        }
                    }
                })
                
            case .Retailer:
                
                // Need to fetch retailers
                FilterManager.defaultManager.fetchRetailers( { (success, results) -> Void in
                    
                    if success
                    {
                        if let categories = results
                        {
                            self.items = categories
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.tableView.reloadData()
                            })
                        }
                    }
                })
                
            default:
                break
            }
        }
    }
    
    // MARK: UI Actions
    func confirmSelection()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Add/Remove
    func addSelection(index: Int)
    {
        if let filterItems = items
        {            
            if filterItems[safe: index] != nil
            {
                if selectedItems == nil
                {
                    selectedItems = Array<FilterObject>()
                }
                
                selectedItems!.append(items![index])
                
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
                if let selections = selectedItems
                {
                    if let desiredKey = filterItems[index].key
                    {
                        selectedItems = selections.filter() { $0.key != desiredKey }
                    }
                }
                
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
        
        // Category, Brand, Retailer
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("CheckmarkCell")!
        
        cell.textLabel?.font = Font.OxygenRegular(size: 14.0)
        
        cell.selectionStyle = .None
        
        if let filterItems = items
        {
            if let item: FilterObject = filterItems[indexPath.row]
            {
                if let itemText = item.name
                {
                    cell.textLabel?.text = itemText
                }
                
                if let selections = selectedItems
                {
                    if selections.contains({ $0.name == item.name })
                    {
                        cell.accessoryType = .Checkmark
                    }
                    else
                    {
                        cell.accessoryType = .None
                    }
                }
                else
                {
                    cell.accessoryType = .None
                }
            }
        }
        
        return cell
}

    // MARK: UITableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let filterItems = items
        {
            if let selectedItem = filterItems[safe: indexPath.row]
            {
                if let desiredKey = selectedItem.key
                {
                    if let selections = selectedItems
                    {
                        if selections.contains( { $0.key == desiredKey } )
                        {
                            // Item is already selected. Clear the selection
                            deleteSelection(indexPath.row)
                            
                            return
                        }
                    }
                    
                    // Select the item
                    addSelection(indexPath.row)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
       return 48.0
    }
}