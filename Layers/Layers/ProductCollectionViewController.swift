//
//  ProductCollectionViewController.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class ProductCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    private let kProductCellIdentfier = "ProductCell"

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewBottomLayoutConstraint: NSLayoutConstraint!
    
    var products: Array<ProductResponse>?
    
    var currentPage: Int?
    
    var refreshControl: UIRefreshControl?
    
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
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = Color.lightGrayColor()
        refreshControl?.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        refreshControl?.layer.zPosition = -1
        collectionView.addSubview(refreshControl!)
        
        currentPage = 1
        
        reloadProducts()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        if let tabBar = navigationController?.tabBarController?.tabBar {
//        collectionViewBottomLayoutConstraint.constant = (-1 * tabBar.bounds.size.height) + 8
//        }
//    }
    
    // MARK: Networking
    func reloadProducts()
    {
        // Get next page of results
        if let page = currentPage where page > 0
        {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            LRSessionManager.sharedManager.loadProductCollection(page, completionHandler: { (success, error, response) -> Void in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                if success
                {
                    if let newProducts: Array<ProductResponse> = response as? Array<ProductResponse>
                    {
                        self.currentPage = page + 1
                        
                        // If this is the first page of results
                        if page == 1
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
                            else
                            {
                                if FilterManager.defaultManager.getCurrentFilter().hasActiveFilters()
                                {
                                    // New filter yielded 0 products. Show Alert
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        
                                        let alert = UIAlertController(title: "NO_RESULTS_FOR_FILTER".localized, message: nil, preferredStyle: .Alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    })
                                }
                            }
                        }
                        else
                        {
                            // If this is a response for page 2 or greater
                            self.products?.appendContentsOf(newProducts)
                            
                            // Update UI
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                //Insert new products
                                self.collectionView.performBatchUpdates({ () -> Void in
                                    
                                    var indexPaths = Array<NSIndexPath>()
                                    
                                    // (Page - 1) represents the first index we want to insert into
                                    let index: Int = (page - 1) * productCollectionPageSize
                                    
                                    // When less items than the productCollectionPageSize are returned, newProducts.count ensures we only try to insert the number of products we have. This avoids an indexOutOfBounds error
                                    for i in index...index+newProducts.count-1
                                    {
                                        indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
                                    }
                                    
                                    self.collectionView.insertItemsAtIndexPaths(indexPaths)
                                    
                                    }, completion: nil)
                            })
                        }
                    }
                }
                else
                {
                    if let products = self.products where self.products?.count > 0
                    {
                        if let loadingCell = self.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: products.count, inSection: 0)) as? LoadingCell
                        {
                            loadingCell.spinner.stopAnimating()
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
                
            })
        }
        else
        {
            let alert = UIAlertController(title: "Page not specified.", message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
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

    // MARK: Collection View Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let items = products where items.count > 0
        {
            return items.count + 1
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let items = products
        {
            if indexPath.row == items.count
            {
                let loadingCell = collectionView.dequeueReusableCellWithReuseIdentifier("LoadingCell", forIndexPath: indexPath) as! LoadingCell
                
                return loadingCell
            }
            
            let product: ProductResponse = items[indexPath.row]
            
            let cell: ProductCell = collectionView.dequeueReusableCellWithReuseIdentifier(kProductCellIdentfier, forIndexPath: indexPath) as! ProductCell
            
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
                        cell.productImageView.sd_setImageWithURL(primaryUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                            
                            if image != nil && cacheType != .Memory
                            {
                                cell.productImageView.alpha = 0.0
                                
                                UIView.animateWithDuration(0.3, animations: {
                                    cell.productImageView.alpha = 1.0
                                })
                            }
                        })
                    }
                }
                
                //Set Price for first size
                if let firstSize = variant.sizes?[safe:  0]
                {
                    if let priceInfo = firstSize.prices?[safe: 0]
                    {
                        var currentPrice: NSNumber?
                        var retailPrice: NSNumber?
                        
                        if let altCouponPrice = firstSize.altPricing?.priceAfterCoupon
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
            if indexPath.row == products.count - 6
            {
                // If last page returned a full list of products, it's highly likely the next page is not empty. This is not perfect, but will reduce unnecessary API calls
                if products.count % productCollectionPageSize == 0
                {
                    // Auto-increments page, so no <page> parameter is required
                    reloadProducts()
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if let products = products
        {
            if indexPath.row == products.count
            {
                // Start Spinner on Loading Cell
                if let loadingCell = cell as? LoadingCell
                {
                    loadingCell.spinner.startAnimating()
                }
            }
        }
    }
    
    // MARK: Collection View Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("ShowProductViewController", sender: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if indexPath.row == products?.count
        {
            // Size for Loading Cell
            return CGSizeMake(collectionView.bounds.size.width - 16, 40.0)
        }
        else
        {
            // Size for Product Cell
            let flowLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            
            let width: CGFloat = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - 8) * 0.5
            
            return CGSizeMake(width, 226.0)
        }
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
                        if let product = productCollection[indexPath.row] as ProductResponse?
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
