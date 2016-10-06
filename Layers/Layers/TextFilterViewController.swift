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
    func textFilterChanged(_ filters: Array<FilterObject>?, filterType: FilterType?)
}

class TextFilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var filterTypeDelegate: FilterTypeDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var selectButton: UIButton!
    
    var filterType: FilterType?
    
    var items: Array<FilterObject>?
    
    var selectedItems: Array<FilterObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        tableView.backgroundColor = Color.BackgroundGrayColor

        // Set the Navigation Title
        setNavTitle()
        
        selectButton.setBackgroundColor(Color.NeonBlueColor, forState: UIControlState())
        selectButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .highlighted)
        
        selectButton.addTarget(self, action: #selector(confirmSelection), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset".uppercased(), style: .plain, target: self, action:#selector(reset))
        
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
                    case .category:
                        
                        delegate.textFilterChanged(filterArray, filterType: FilterType.category)
                        
                    case .brand:
                        
                        delegate.textFilterChanged(filterArray, filterType: FilterType.brand)
                        
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
            case .category:
                
                title = "Category".uppercased()
                
            case .brand:
                
                title = "Brand".uppercased()
                
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
            case .category:
                
                FilterManager.defaultManager.fetchOriginalCategories( { (success, results) -> Void in
                    
                    if success
                    {
                        if let categories = results as? Array<Category>
                        {
                            let filterObjects = FilterObjectConverter.filterObjectArray(categories)
                            
                            self.items = filterObjects
                            
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.tableView.reloadData()
                            })
                        }
                    }
                })
                
            case .brand:
                
                //Need to fetch brands
                FilterManager.defaultManager.fetchBrands( { (success, results) -> Void in
                    
                    if success
                    {
                        if let categories = results
                        {
                            self.items = categories
                            
                            DispatchQueue.main.async(execute: { () -> Void in
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
        navigationController?.popViewController(animated: true)
    }
    
    func reset()
    {
        selectedItems = nil
        
        tableView.reloadData()
    }
    
    // MARK: Add/Remove
    func addSelection(_ index: Int)
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

    func deleteSelection(_ index: Int)
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
    
    func updateRowAtIndex(_ index: Int)
    {
        tableView.beginUpdates()
        
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        
        tableView.endUpdates()
    }
    
    // MARK: UITableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let type = filterType
        {
            if type == FilterType.price
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Category, Brand, Retailer
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkCell")!
        
        cell.textLabel?.font = Font.OxygenRegular(size: 14.0)
        
        cell.selectionStyle = .none
        
        if let filterItems = items
        {
            if let item: FilterObject = filterItems[(indexPath as NSIndexPath).row]
            {
                if let itemText = item.name
                {
                    cell.textLabel?.text = itemText
                }
                
                if let selections = selectedItems
                {
                    if selections.contains(where: { $0.name == item.name })
                    {
                        cell.accessoryType = .checkmark
                    }
                    else
                    {
                        cell.accessoryType = .none
                    }
                }
                else
                {
                    cell.accessoryType = .none
                }
            }
        }
        
        return cell
}

    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let filterItems = items
        {
            if let selectedItem = filterItems[safe: (indexPath as NSIndexPath).row]
            {
                if let desiredKey = selectedItem.key
                {
                    if let selections = selectedItems
                    {
                        if selections.contains( where: { $0.key == desiredKey } )
                        {
                            // Item is already selected. Clear the selection
                            deleteSelection((indexPath as NSIndexPath).row)
                            
                            return
                        }
                    }
                    
                    // Select the item
                    addSelection((indexPath as NSIndexPath).row)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
       return 48.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 24.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 24.0
    }
    
    
    
    
}
