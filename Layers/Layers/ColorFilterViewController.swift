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
    func colorFilterChanged(_ colors: Array<ColorObject>?)
}

class ColorFilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: ColorFilterDelegate?
    
    var filterType: FilterType?
    
    var colors: Array<ColorObject>?
    
    var selectedColors: Array<ColorObject>?
    
    @IBOutlet weak var selectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Color".uppercased()
        
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.backgroundColor = UIColor.white
        
        setNavTitle()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset".uppercased(), style: .plain, target: self, action:#selector(reset))

        selectButton.setBackgroundColor(Color.NeonBlueColor, forState: UIControlState())
        selectButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .highlighted)
        
        selectButton.addTarget(self, action: #selector(confirmSelection), for: .touchUpInside)
        
        reloadColors()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        if filterType == FilterType.color
        {
            title = "Color".uppercased()
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
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        self.collectionView.reloadData()
                    })
                }
            }
        })
    }
    
    // MARK: UI Actions
    func confirmSelection()
    {
        navigationController?.popViewController(animated: true)
    }
    
    func reset()
    {
        selectedColors = nil
        
        collectionView.reloadData()
    }
    
    // MARK: Add/Remove
    func addSelection(_ index: Int)
    {
        if let filterColors = colors
        {
            if filterColors[safe: index] != nil
            {
                if selectedColors == nil
                {
                    selectedColors = Array<ColorObject>()
                }
                
                selectedColors!.append(colors![index])
                
                updateRowAtIndex(index)
            }
        }
    }
    
    func deleteSelection(_ index: Int)
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
    
    func updateRowAtIndex(_ index: Int)
    {
        UIView.setAnimationsEnabled(false)
        
        collectionView.performBatchUpdates({ () -> Void in
            
            self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            
            }, completion: { (finished) -> Void in
                
                UIView.setAnimationsEnabled(true)
        })
    }
    
    // MARK: Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let colors = colors
        {
            return colors.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        
        if let colors = colors
        {
//            let currentColor: ColorObject = colors[indexPath.row]
//            
//            if let color = Color.colorFromHex(currentColor.colorHex)
//            {
//                //Darken white so that it's visible on screen
//                if currentColor.colorHex == "FFFFFF"
//                {
//                    cell.colorSwatchView.backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
//                }
//                else
//                {
//                    cell.colorSwatchView.backgroundColor = color
//                }
//            }
//            
//            if let colorName = currentColor.colorName
//            {
//                cell.textLabel.text = colorName.capitalizedString
//            }
//            
//            // Show checkmark if selected
//            if let selections = selectedColors
//            {
//                if selections.contains({ $0.colorName == currentColor.colorName })
//                {
//                    cell.checkmarkImageView.hidden = false
//                }
//                else
//                {
//                    cell.checkmarkImageView.hidden = true
//                }
//            }
//            else
//            {
//                cell.checkmarkImageView.hidden = true
//            }
        }
        
        return cell
    }
    
    // MARK: Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Add/remove color
        if let filterColors = colors
        {
            if let selectedColor = filterColors[safe: (indexPath as NSIndexPath).row]
            {
                if let desiredKey = selectedColor.colorId
                {
                    if let selections = selectedColors
                    {
                        if selections.contains( where: { $0.colorId == desiredKey } )
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Size for Product Cell
        let flowLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let width: CGFloat = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - 8) * 0.25
        
        return CGSize(width: width, height: 104.0)
    }
}
