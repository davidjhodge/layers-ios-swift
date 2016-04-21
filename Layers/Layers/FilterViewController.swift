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

private enum FilterType: Int
{
    case Price = 0, Category, Brand, Color, Count
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
        return FilterType.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let filterType = FilterType(rawValue: section)
        {
            switch filterType {
            case .Price:
                
                return 1
                
            case .Category:
                
                //Some categories + Search
                return 2
                
            case .Brand:
                
                return 2
                
            case .Color:
                
                //Colors
                return 2
                
            default:
                return 0
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let filterType = FilterType(rawValue: indexPath.section)
        {
            switch filterType {
            case .Price:
                
                let priceCell: SliderCell = tableView.dequeueReusableCellWithIdentifier("SliderCell") as! SliderCell
                
                priceCell.minLabel.text = "$0"
                
                priceCell.maxLabel.text = "$100"
                
                priceCell.slider.addTarget(self, action: #selector(sliderValueChanged(_:)), forControlEvents: .ValueChanged)
                
                //To identify the slider when value changes
                priceCell.slider.tag = indexPath.row
                
                priceCell.selectionStyle = .None
                
                return priceCell
                
            case .Category:
                
                let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("CheckmarkCell") as UITableViewCell!
                
                cell.textLabel!.text = "T-Shirts"
                
                cell.textLabel?.font = Font.OxygenRegular(size: 16.0)

                cell.accessoryType = .None
                
                cell.selectionStyle = .None
                
                return cell
                
            case .Brand:
                
                let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("CheckmarkCell") as UITableViewCell!
                
                cell.textLabel!.text = "Burberry"
                
                cell.textLabel?.font = Font.OxygenRegular(size: 16.0)

                cell.accessoryType = .None
                
                cell.selectionStyle = .None
                
                return cell
//            case .Color:
//                
//                //Colors
//                return 2
                
            default:
                return UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
            }
        }
        
        return UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let filterType = FilterType(rawValue: section)
        {
            switch filterType {
            case .Price:
                
                return "Price".uppercaseString
                
            case .Category:
                
                //Some categories + Search
                return "Categories".uppercaseString
                
            case .Brand:
                
                return "Brands".uppercaseString
                
            case .Color:
                
                //Colors
                return "Colors".uppercaseString
                
            default:
                return ""
            }
        }
        
        return ""
    }
    
    // MARK: Table View Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let filterType = FilterType(rawValue: indexPath.section)
        {
            switch filterType {
//            case .Price:
//                
//                return 64
//                
            case .Category:
                
                //Should update the model and then update view based on model changes
                if let selectedCell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)
                {
                    if selectedCell.accessoryType == .None
                    {
                        selectedCell.accessoryType = .Checkmark
                    }
                    else
                    {
                        if selectedCell.accessoryType == .Checkmark
                        {
                            selectedCell.accessoryType = .None
                        }
                    }
                }
                
            case .Brand:
                
                //Should update the model and then update view based on model changes
                if let selectedCell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)
                {
                    if selectedCell.accessoryType == .None
                    {
                        selectedCell.accessoryType = .Checkmark
                    }
                    else
                    {
                        if selectedCell.accessoryType == .Checkmark
                        {
                            selectedCell.accessoryType = .None
                        }
                    }
                }
//            case .Color:
//                
//                //Colors
//                break
                
            default:
                break
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let filterType = FilterType(rawValue: indexPath.section)
        {
            switch filterType {
            case .Price:
                
                return 64
                
            case .Category:
                
                //Some categories + Search
                return 48
                
            case .Brand:
                
                return 48
                
            case .Color:
                
                //Colors
                return 48
                
            default:
                return 0
            }
        }
        
        return 0
    }
}