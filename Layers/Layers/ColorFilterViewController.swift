//
//  ColorFilterViewController.swift
//  Layers
//
//  Created by David Hodge on 5/13/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

protocol ColorFilterDelegate
{
    func colorFilterChanged(colors: Array<ColorResponse>?)
}

class ColorFilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: ColorFilterDelegate?
    
    var filterType: FilterType?
    
    var colors: Array<ColorResponse>?
    
    var selectedColors: Array<ColorResponse>?
    
    @IBOutlet weak var selectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Color".uppercaseString
        
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.backgroundColor = UIColor.whiteColor()
        
        setNavTitle()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset".uppercaseString, style: .Plain, target: self, action:#selector(reset))

        selectButton.setBackgroundColor(Color.NeonBlueColor, forState: .Normal)
        selectButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .Highlighted)
        
        selectButton.addTarget(self, action: #selector(confirmSelection), forControlEvents: .TouchUpInside)
        
        reloadColors()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let colorSelections = selectedColors
        {
            if colorSelections.count > 0
            {
                delegate?.colorFilterChanged(colorSelections)
            }
            else
            {
                delegate?.colorFilterChanged(nil)
            }
        }
        else
        {
            delegate?.colorFilterChanged(nil)
        }
    }
    
    func setNavTitle()
    {
        if filterType == FilterType.Color
        {
            title = "Color".uppercaseString
        }
    }
    
    func reloadColors()
    {
        FilterManager.defaultManager.fetchColors({ (success, response) -> Void in
            
            if success
            {
                if let fetchedColors = response
                {
                    self.colors = fetchedColors
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.collectionView.reloadData()
                    })
                }
            }
        })
    }
    
    // MARK: UI Actions
    func confirmSelection()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func reset()
    {
        selectedColors = nil
        
        collectionView.reloadData()
    }
    
    // MARK: Add/Remove
    func addSelection(index: Int)
    {
        if let filterColors = colors
        {
            if filterColors[safe: index] != nil
            {
                if selectedColors == nil
                {
                    selectedColors = Array<ColorResponse>()
                }
                
                selectedColors!.append(colors![index])
                
                updateRowAtIndex(index)
            }
        }
    }
    
    func deleteSelection(index: Int)
    {
        if let filterColors = colors
        {
            if filterColors[safe: index] != nil
            {
                if let selections = selectedColors
                {
                    if let desiredKey = filterColors[index].colorId
                    {
                        selectedColors = selections.filter() { $0.colorId != desiredKey }
                    }
                }
                
                updateRowAtIndex(index)
            }
        }
    }
    
    func updateRowAtIndex(index: Int)
    {
        UIView.setAnimationsEnabled(false)
        
        collectionView.performBatchUpdates({ () -> Void in
            
            self.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
            
            }, completion: { (finished) -> Void in
                
                UIView.setAnimationsEnabled(true)
        })
    }
    
    // MARK: Collection View Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let colors = colors
        {
            return colors.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColorCell", forIndexPath: indexPath) as! ColorCell
        
        if let colors = colors
        {
            let currentColor: ColorResponse = colors[indexPath.row]
            
            if let color = Color.colorFromHex(currentColor.colorHex)
            {
                //Darken white so that it's visible on screen
                if currentColor.colorHex == "FFFFFF"
                {
                    cell.colorSwatchView.backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
                }
                else
                {
                    cell.colorSwatchView.backgroundColor = color
                }
            }
            
            if let colorName = currentColor.colorName
            {
                cell.textLabel.text = colorName.capitalizedString
            }
            
            // Show checkmark if selected
            if let selections = selectedColors
            {
                if selections.contains({ $0.colorName == currentColor.colorName })
                {
                    cell.checkmarkImageView.hidden = false
                }
                else
                {
                    cell.checkmarkImageView.hidden = true
                }
            }
            else
            {
                cell.checkmarkImageView.hidden = true
            }
        }
        
        return cell
    }
    
    // MARK: Collection View Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Add/remove color
        if let filterColors = colors
        {
            if let selectedColor = filterColors[safe: indexPath.row]
            {
                if let desiredKey = selectedColor.colorId
                {
                    if let selections = selectedColors
                    {
                        if selections.contains( { $0.colorId == desiredKey } )
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // Size for Product Cell
        let flowLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let width: CGFloat = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - 8) * 0.25
        
        return CGSizeMake(width, 104.0)
    }
}