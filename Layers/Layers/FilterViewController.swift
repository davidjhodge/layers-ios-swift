//
//  FilterViewController.swift
//  Layers
//
//  Created by David Hodge on 4/19/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum FilterType: Int
{
    case category = 0, brand, price, color, count
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
        
        title = "Filter".uppercased()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change status bar style to .LightContent
        navigationController?.navigationBar.barStyle = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".uppercased(), style: .plain, target: self, action: #selector(cancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset".uppercased(), style: .plain, target: self, action: #selector(reset))
        
        tableView.backgroundColor = Color.BackgroundGrayColor
        
        applyButton.setBackgroundColor(Color.NeonBlueColor, forState: UIControlState())
        applyButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .highlighted)

        applyButton.addTarget(self, action: #selector(applyFilter), for: .touchUpInside)
        
        if !newFilter.hasActiveFilters()
        {
            applyButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if applyButton.isHidden == false
        {
            if !newFilter.hasActiveFilters()
            {
                applyButton.isHidden = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if applyButton.isHidden == true
        {
            if newFilter.hasActiveFilters()
            {
                let transition: CATransition = CATransition()
                transition.duration = 0.2
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromLeft
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                applyButton.layer.add(transition, forKey: nil)
                
                applyButton.isHidden = false
            }
        }
    }
    
    // MARK: Actions
    func cancel()
    {
        dismiss(animated: true, completion: nil)
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
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: FilterTypeDelegate
    func textFilterChanged(_ filters: Array<FilterObject>?, filterType: FilterType?)
    {
        if let type = filterType
        {
            switch type {
            case .category:
                
                newFilter.categories.selections = filters
                
            case .brand:
                
                newFilter.brands.selections = filters
                
            default:
                break
            }
            
            // Would be better practice to only reload the cell we updated
            tableView.reloadData()
        }
    }
    
    func priceFilterChanged(_ priceFilter: PriceFilter?) {
        
        if let priceFilter = priceFilter
        {
            if priceFilter.minPrice?.intValue >= 0 && priceFilter.maxPrice?.intValue > 0
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
    func colorFilterChanged(_ colors: Array<ColorObject>?) {
        
        newFilter.colors.selections = colors
        
        // Should reload just the color row to improve efficiency
        tableView.reloadData()
    }
    
    // MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FilterType.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleFilterCell") as! SubtitleFilterCell
        
        cell.accessoryType = .disclosureIndicator
        
        cell.filterTypeLabel.text = ""
        cell.filterSelectionLabel.text = ""
        cell.selectedCircleView.isHidden = true

        if let filterType = FilterType(rawValue: (indexPath as NSIndexPath).row)
        {
            switch filterType {
                
            case .category:

                cell.filterTypeLabel.text = "Category".uppercased()
                
                if let categorySelections = newFilter.categories.selections
                {
                    if categorySelections.count == 1
                    {
                        if let firstCategoryName = categorySelections.first?.name
                        {
                            cell.filterSelectionLabel.text = firstCategoryName.capitalized
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
                    cell.selectedCircleView.isHidden = false
                }
                else
                {
                    cell.selectedCircleView.isHidden = true
                }
                
            case .brand:
                
                cell.filterTypeLabel.text = "Brand".uppercased()
                
                if let brandSelections = newFilter.brands.selections
                {
                    if brandSelections.count == 1
                    {
                        if let firstBrandName = brandSelections.first?.name
                        {
                            cell.filterSelectionLabel.text = firstBrandName.capitalized
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
                    cell.selectedCircleView.isHidden = false
                }
                else
                {
                    cell.selectedCircleView.isHidden = true
                }
                
            case .price:
                
                cell.filterTypeLabel.text = "Price".uppercased()

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
                    cell.selectedCircleView.isHidden = false
                }
                else
                {
                    cell.selectedCircleView.isHidden = true
                }
            
            case .color:
                
                cell.filterTypeLabel.text = "Color".uppercased()
                
                if let colorSelections = newFilter.colors.selections
                {
                    if colorSelections.count == 1
                    {
                        if let firstColorName = colorSelections.first?.name
                        {
                            cell.filterSelectionLabel.text = firstColorName.capitalized
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
                    cell.selectedCircleView.isHidden = false
                }
                else
                {
                    cell.selectedCircleView.isHidden = true
                }
                
            default:
                return cell
            }
        }
        
        return cell
    }
    
    // MARK: Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let filterType = FilterType(rawValue: (indexPath as NSIndexPath).row)
        {
            switch filterType {
 
            case .category:
                // Use the logic for .Brand
                fallthrough
                
            case .brand:

                performSegue(withIdentifier: "ShowTextFilterViewController", sender:filterType.rawValue)
                
            case .price:
                
                performSegue(withIdentifier: "ShowPriceFilterViewController", sender:filterType.rawValue)
                
            case .color:

                performSegue(withIdentifier: "ShowColorFilterViewController", sender:filterType.rawValue)

                break
                
            default:
                break
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 24.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 24.0
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowTextFilterViewController"
        {
            if let destinationVc = segue.destination as? TextFilterViewController
            {
                if let senderRawValue = sender as? Int
                {
                    if let type = FilterType(rawValue: senderRawValue)
                    {
                        destinationVc.filterType = type
                        destinationVc.filterTypeDelegate = self

                        switch type {
                        case .category:
                            
                            if let currentFilters = newFilter.categories.selections
                            {
                                var array = Array<FilterObject>()
                                
                                for currFilter in currentFilters
                                {
                                    array.append(currFilter)
                                }
                                
                                destinationVc.selectedItems = array
                            }
                            
                        case .brand:
                            
                            if let currentFilters = newFilter.brands.selections
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
            if let destinationVc = segue.destination as? PriceFilterViewController
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
            if let destinationVc = segue.destination as? ColorFilterViewController
            {
                destinationVc.delegate = self
                
                if let currentFilters = newFilter.colors.selections
                {
                    var array = Array<ColorObject>()
                    
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
