//
//  OnboardingBrandsViewController.swift
//  Layers
//
//  Created by David Hodge on 4/23/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

struct Brand: Equatable
{
    var title: String?
    
    var logoImageName: String?
    
    var highlightedImageName: String?
}

// Comparison
func ==(lhs:Brand, rhs:Brand) -> Bool { // Implement Equatable
    return lhs.title == rhs.title &&
        lhs.logoImageName == rhs.logoImageName &&
        lhs.highlightedImageName == rhs.highlightedImageName}

class OnboardingBrandsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    var brandList: Array<Brand>?
    
    var selectedBrands: Array<Brand>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nike = Brand(title: "Nike", logoImageName: "nike-logo.png", highlightedImageName: "nike-logo-highlighted.png")
        let adidas = Brand(title: "Adidas", logoImageName: "nike-logo.png", highlightedImageName: "nike-logo-highlighted.png")
        let ua = Brand(title: "Under Armour", logoImageName: "nike-logo.png", highlightedImageName: "nike-logo-highlighted.png")

        brandList = [nike,adidas,ua,nike,nike,nike,nike,nike]
        
        selectedBrands = []
        
        skipButton.addTarget(self, action: #selector(skip), forControlEvents: .TouchUpInside)
        
        nextButton.addTarget(self, action: #selector(next), forControlEvents: .TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kProgressViewNeedsUpdateNotification, object: nil, userInfo: ["hidden": false,
            "progress": 0.6]))
    }
    
    // MARK: Actions
    func skip()
    {
        performSegueWithIdentifier("ShowOnboardingAgeViewController", sender: self)
    }
    
    func next()
    {
        performSegueWithIdentifier("ShowOnboardingAgeViewController", sender: self)
    }
    
    // MARK: Button Interactivity
    func disableButtons()
    {
        skipButton.userInteractionEnabled = false
        nextButton.userInteractionEnabled = false
    }
    
    func enableButtons()
    {
        skipButton.userInteractionEnabled = true
        nextButton.userInteractionEnabled = true
    }
    
    func updateNextButton()
    {
        if let brandSelections = selectedBrands
        {
            if brandSelections.count >= 3
            {
                if self.nextButton.userInteractionEnabled == false
                {
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        self.nextButton.userInteractionEnabled = true
                        self.nextButton.backgroundColor = Color.NeonBlueColor
                    })
                }
            }
            else
            {
                if self.nextButton.userInteractionEnabled == true
                {
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        self.nextButton.userInteractionEnabled = false
                        self.nextButton.backgroundColor = Color.LightGray
                    })
                }
            }
        }
    }
    
    // MARK: Collection View Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let brands = brandList
        {
            return brands.count
        }
        
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: BrandCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("BrandCollectionCell", forIndexPath: indexPath) as! BrandCollectionCell
        
        if let brands = brandList
        {
            let brand = brands[indexPath.row]
            
            if let brandTitle = brand.title
            {
                cell.brandLabel.text = brandTitle
            }
            
            if let imageName = brand.logoImageName
            {
                cell.logoImageView.image = UIImage(named: imageName)
            }
        }
        
        return cell
    }
    
    // MARK: Collection View Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if var brands = brandList
        {
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! BrandCollectionCell
            
            let brand = brands[indexPath.row]
            
            if selectedBrands != nil
            {
                if selectedBrands!.contains(brand)
                {
                    if let index = selectedBrands!.indexOf(brand)
                    {
                        selectedBrands!.removeAtIndex(index)
                    }
                    
                    selectedCell.setDefault()
                    
                    if let imageName = brand.logoImageName
                    {
                        selectedCell.logoImageView.image = UIImage(named: imageName)
                    }
                    
                    
                }
                else
                {
                    selectedBrands!.append(brand)
                    
                    selectedCell.setHighlighted()
                    if let imageName = brand.highlightedImageName
                    {
                        selectedCell.logoImageView.image = UIImage(named: imageName)
                    }
                }

            }
            
            updateNextButton()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(128.0, 128.0)
    }
    
}