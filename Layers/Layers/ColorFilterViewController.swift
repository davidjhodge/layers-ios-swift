//
//  ColorFilterViewController.swift
//  Layers
//
//  Created by David Hodge on 5/13/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

// To organize sorting colors
struct ColorObject
{
    var color: UIColor?
    
    var name: String?
}

class ColorFilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var collectionView: UICollectionView!
    
    var filterType: FilterType?
    
    var colors: Array<ColorObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        //TEMP
        colors = Array<ColorObject>()
        
        var color1 = ColorObject()
        color1.color = Color.NeonBlueColor
        color1.name = "Blue"
        colors?.append(color1)
        colors?.append(color1)
        colors?.append(color1)
        colors?.append(color1)
        
        setNavTitle()
    }
    
    func setNavTitle()
    {
        if filterType == FilterType.Color
        {
            title = "Color".uppercaseString
        }
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
            let currentColor: ColorObject = colors[indexPath.row]
            
            if let colorValue = currentColor.color
            {
                cell.colorSwatchView.backgroundColor = colorValue
            }
            
            if let colorName = currentColor.name
            {
                cell.textLabel.text = colorName
            }
        }
        
        return cell
    }
    
    // MARK: Collection View Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Add/remove color
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(68.0,88.0)
    }
}