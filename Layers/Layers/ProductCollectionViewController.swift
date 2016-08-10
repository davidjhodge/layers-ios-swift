//
//  ProductCollectionViewController.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import NHAlignmentFlowLayout
import SDWebImage

class ProductCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    private let kProductCellIdentfier = "ProductCell"

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewBottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emptyStateView: UIView!
    
    @IBOutlet weak var emptyStateButton: UIButton!

    var products: Array<SimpleProductResponse>?
    
    var currentPage: Int?
    
    var refreshControl: UIRefreshControl?
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let titleLabel = UILabel(frame: CGRectMake(0,0,28,80))
        titleLabel.attributedText = NSAttributedString(string: "Layers".uppercaseString, attributes: [NSForegroundColorAttributeName: Color.whiteColor(),
            NSFontAttributeName: Font.CharterBold(size: 20.0),
            NSKernAttributeName: 2.0]
        )
        navigationItem.titleView = titleLabel
        
        tabBarItem.title = "Discover".uppercaseString
        tabBarItem.image = UIImage(named: "shirt")
        tabBarItem.image = UIImage(named: "shirt-filled")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = Color.lightGrayColor()
        refreshControl?.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        collectionView.addSubview(refreshControl!)
        
        // Flow Layout
        let customLayout = NHAlignmentFlowLayout()
        customLayout.scrollDirection = .Vertical
        customLayout.alignment = .TopLeftAligned
        customLayout.minimumLineSpacing = 8.0
        customLayout.minimumInteritemSpacing = 8.0
        customLayout.sectionInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        collectionView.collectionViewLayout = customLayout
        
        emptyStateButton.setBackgroundColor(Color.NeonBlueColor, forState: .Normal)
        emptyStateButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .Highlighted)
        
        emptyStateButton.addTarget(self, action: #selector(showSearchTab), forControlEvents: .TouchUpInside)
        
        spinner.hidesWhenStopped = true
        spinner.hidden = true
        spinner.color = Color.grayColor()
        view.addSubview(spinner)
                
        reloadProducts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        spinner.center = collectionView.center
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    // MARK: Networking
    func reloadProducts()
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        if emptyStateView.hidden == false
        {
            collectionView.hidden = false
            
            emptyStateView.hidden = true
        }
        
        LRSessionManager.sharedManager.loadDiscoverProducts({ (success, error, response) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if success
            {
                if let newProducts: Array<SimpleProductResponse> = response as? Array<SimpleProductResponse>
                {
                    if newProducts.count > 0
                    {
                        // Update products and reload collection
                        self.products = newProducts
                        
                        // If refresh control is active. Reload data after refresh indicator disappears
                        if let refresh = self.refreshControl
                        {
                            if refresh.refreshing
                            {
                                // Log Refresh
                                FBSDKAppEvents.logEvent("Discover Refresh Events")
                                
                                CATransaction.begin()
                                CATransaction.setCompletionBlock({ () -> Void in
                                    
                                    self.hardReloadCollectionView()
                                })
                                
                                refresh.endRefreshing()
                                CATransaction.commit()
                            }
                            else
                            {
                                // By default, refresh collection view immediately
                                self.hardReloadCollectionView()
                            }
                        }
                        else
                        {
                            // By default, refresh collection view immediately
                            self.hardReloadCollectionView()
                        }
                    }
                }
                
                if self.products == nil || self.products?.count == 0
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.collectionView.hidden = true
                        
                        self.emptyStateView.hidden = false
                    })
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
            
            if let refresh = self.refreshControl
            {
                if refresh.refreshing
                {
                    refresh.endRefreshing()
                }
            }
        })
    }
    
    func loadMoreProducts()
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        LRSessionManager.sharedManager.loadDiscoverProducts({ (success, error, response) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if success
            {
                if let newProducts: Array<SimpleProductResponse> = response as? Array<SimpleProductResponse>
                {
                    // If this is a response for page 2 or greater
                    self.products?.appendContentsOf(newProducts)
                    
                    // Update UI
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        let topOffset = self.collectionView.contentOffset.y
                        
                        //Insert new products
                        CATransaction.begin()
                        CATransaction.setDisableActions(true)
                        
                        self.collectionView.performBatchUpdates({ () -> Void in
                            
                            var indexPaths = Array<NSIndexPath>()
                            
                            // (Page - 1) represents the first index we want to insert into
                            if let products = self.products
                            {
                                let index: Int = products.count - newProducts.count
                                
                                // When less items than the productCollectionPageSize are returned, newProducts.count ensures we only try to insert the number of products we have. This avoids an indexOutOfBounds error
                                for i in index...index+newProducts.count-1
                                {
                                    indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
                                }
                                
                                self.collectionView.insertItemsAtIndexPaths(indexPaths)
                                
                            }
                            }, completion: { (finished) -> Void in
                                
                                // Set correct content offset
                                self.collectionView.contentOffset = CGPointMake(0, topOffset)
                                CATransaction.commit()
                        })
                    })
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        })
    }
    
    func hardReloadCollectionView()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.collectionView.reloadData()
            
            self.collectionView.setContentOffset(CGPointZero, animated: false)
        })
    }
    
    // MARK: Actions
    func refresh()
    {
        currentPage = 1
        
        reloadProducts()
    }
    
    func showSearchTab()
    {
        if let tabBarVc = tabBarController
        {
            tabBarVc.selectedIndex = 1
        }
    }

    // MARK: Collection View Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let items = products where items.count > 0
        {
            return items.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let items = products
        {
            let product: SimpleProductResponse = items[indexPath.row]
            
            let cell: ProductCell = collectionView.dequeueReusableCellWithReuseIdentifier(kProductCellIdentfier, forIndexPath: indexPath) as! ProductCell
            
            cell.brandLabel.text = ""
            cell.productImageView.image = nil
            cell.priceLabel.text = ""
            
            // If no color filters are activated, use the first variant. Else, use the first variant with a matching color.
            var variant: Variant?
            
            if let variants = product.variants
            {
                // Returns a variant that matches the color
                if let matchingVariant = Variant.variantMatchingFilterColorsInVariants(variants)
                {
                    variant = matchingVariant
                }
            }

            if variant == nil
            {
                if let firstVariant = product.variants?[safe: 0]
                {
                    variant = firstVariant
                }
            }
            
            if let variant = variant
            {
                //Set Image View with first image
                if let firstImage = variant.images?[safe: 0]
                {
                    if let primaryUrl = firstImage.primaryUrl
                    {
                        let resizedPrimaryUrl = NSURL.imageAtUrl(primaryUrl, imageSize: ImageSize.kImageSize116)
                        
                        cell.productImageView.sd_setImageWithURL(resizedPrimaryUrl, placeholderImage: nil, options: SDWebImageOptions.ProgressiveDownload, completed: { (image, error, cacheType, imageUrl) -> Void in

//                        cell.productImageView.sd_setImageWithURL(resizedPrimaryUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                        
//                            if image != nil && cacheType != .Memory
//                            {
//                                cell.productImageView.alpha = 0.0
//                                
//                                UIView.animateWithDuration(0.3, animations: {
//                                    cell.productImageView.alpha = 1.0
//                                    })
//                            }
                        })
                    }
                }
                
                //Set Price for first size
                if let firstSize = variant.sizes?[safe:  0]
                {
                    if let priceInfo = firstSize.price
                    {
                        var currentPrice: NSNumber?
                        var retailPrice: NSNumber?
                        
                        if let altCouponPrice = firstSize.altPrice?.priceAfterCoupon
                        {
                            currentPrice = altCouponPrice
                        }
                        else if let currPrice = priceInfo.price
                        {
                            currentPrice = currPrice
                        }
                        
                        if let retail = priceInfo.retailPrice
                        {
                            retailPrice = retail
                        }
                        
                        cell.priceLabel.attributedText = NSAttributedString.priceStringWithRetailPrice(retailPrice, salePrice: currentPrice)
                    }
                }
            }
            
            if let brandName = product.brand?.brandName
            {
                cell.brandLabel.text = brandName.uppercaseString
            }
            
            return cell
        }
        
        return collectionView.dequeueReusableCellWithReuseIdentifier(kProductCellIdentfier, forIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if let products = products
        {
            // Insert next page of items as we near the end of the current list
            if indexPath.row == products.count - 4
            {
                // If last page returned a full list of products, it's highly likely the next page is not empty. This is not perfect, but will reduce unnecessary API calls
                loadMoreProducts()
            }
        }
    }
    
    // MARK: Collection View Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("ShowProductViewController", sender: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // Size for Product Cell
        let flowLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let width: CGFloat = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - 8) * 0.5
        
        return CGSizeMake(width, 226.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.HighlightedGrayColor
                
                if let productCell = cell as? ProductCell
                {
                    productCell.productImageView.alpha = 0.5
                }
                
                }, completion: nil)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.whiteColor()
                
                if let productCell = cell as? ProductCell
                {
                    productCell.productImageView.alpha = 1.0
                }
                
                }, completion: nil)
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowProductViewController"
        {
            if segue.destinationViewController is ProductViewController
            {
//                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)

                //Selected Product Index
                if let indexPath = sender as? NSIndexPath
                {
                    if let productCollection = products
                    {
                        if let product = productCollection[indexPath.row] as SimpleProductResponse?
                        {
                            if let destinationVC = segue.destinationViewController as? ProductViewController
                            {
                                destinationVC.productIdentifier = product.productId
                            }
                        }
                    }
                }
            }
        }
    }
}
