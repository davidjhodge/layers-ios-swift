//
//  DiscoverViewController.swift
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
import KLCPopup

class DiscoverViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewBottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emptyStateView: EmptyStateView!
    
    @IBOutlet weak var emptyStateButton: UIButton!

    var products: Array<Product>?
    
    var currentPage: Int?
    
    var refreshControl: UIRefreshControl?
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let titleLabel = UILabel(frame: CGRectMake(0,0,28,80))
        titleLabel.attributedText = NSAttributedString(string: "Layers".uppercaseString, attributes: [NSForegroundColorAttributeName: Color.whiteColor(),
            NSFontAttributeName: Font.PrimaryFontRegular(size: 18.0),
            NSKernAttributeName: 2.5]
        )
        navigationItem.titleView = titleLabel
        
        tabBarItem.title = "Discover"
        tabBarItem.image = UIImage(named: "shirt")
        tabBarItem.selectedImage = UIImage(named: "shirt-filled")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change status bar style to .LightContent
        navigationController?.navigationBar.barStyle = .Black
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = Color.lightGrayColor()
        refreshControl?.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        refreshControl?.layer.zPosition = -1
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !LRSessionManager.sharedManager.hasSeenDiscoverPopup()
        {
            if let popupView = NSBundle.mainBundle().loadNibNamed("DiscoverPopup", owner: self, options: nil)[0] as? DiscoverPopupView
            {
                let discoverPopup = KLCPopup(contentView: popupView, showType: .BounceIn, dismissType: .BounceOut, maskType: .Dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: true)
                
                discoverPopup!.show()
                
                LRSessionManager.sharedManager.completeDiscoverPopupExperience()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        spinner.center = collectionView.center
    }
    
    // MARK: Networking
    func reloadProducts()
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        if self.products == nil || self.products?.count == 0
        {
            self.spinner.startAnimating()
        }
        
        if emptyStateView.hidden == false
        {
            toggleErrorState(true, error: false)
        }
        
        LRSessionManager.sharedManager.loadProduct(NSNumber(int: 512141429), completionHandler: { (success, error, response) -> Void in
            
            if success
            {
                if let product = response as? Product
                {
                    self.products = [product]
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.collectionView.reloadData()
                    })
                }
            }
            else
            {
                log.error(error)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.refreshControl?.endRefreshing()
                
                self.spinner.stopAnimating()
            })
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
        
//        LRSessionManager.sharedManager.loadDiscoverProducts({ (success, error, response) -> Void in
//            
//            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//            
//            if success
//            {
//                if let newProducts: Array<Product> = response as? Array<Product>
//                {
//                    if newProducts.count > 0
//                    {
//                        // Update products and reload collection
//                        self.products = newProducts
//                        
//                        // If refresh control is active. Reload data after refresh indicator disappears
//                        if let refresh = self.refreshControl
//                        {
//                            if refresh.refreshing
//                            {
//                                // Log Refresh
//                                FBSDKAppEvents.logEvent("Discover Refresh Events")
//                                
//                                CATransaction.begin()
//                                CATransaction.setCompletionBlock({ () -> Void in
//                                    
//                                    self.hardReloadCollectionView()
//                                })
//                                
//                                refresh.endRefreshing()
//                                CATransaction.commit()
//                            }
//                            else
//                            {
//                                // By default, refresh collection view immediately
//                                self.hardReloadCollectionView()
//                            }
//                        }
//                        else
//                        {
//                            // By default, refresh collection view immediately
//                            self.hardReloadCollectionView()
//                        }
//                    }
//                }
//                
//                if self.products == nil || self.products?.count == 0
//                {
//                    self.toggleErrorState(false, error: false)
//                }
//            }
//            else
//            {
//                log.error(error)
//                
//                self.toggleErrorState(false, error: true)
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                
//                self.spinner.stopAnimating()
//                
//                if let refresh = self.refreshControl
//                {
//                    if refresh.refreshing
//                    {
//                        refresh.endRefreshing()
//                    }
//                }
//            })
//        })
    }
    
    func loadMoreProducts()
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        LRSessionManager.sharedManager.loadDiscoverProducts({ (success, error, response) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if success
            {
                if let newProducts: Array<Product> = response as? Array<Product>
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
    
    func toggleErrorState(hidden: Bool, error: Bool)
    {
        if hidden == true
        {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.collectionView.hidden = false
                
                self.emptyStateView.hidden = true
            })
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if error
                {
                    self.emptyStateView.emptyStateButton.setTitle("Retry".uppercaseString, forState: .Normal)
                    self.emptyStateView.emptyStateButton.setTitle("Retry".uppercaseString, forState: .Highlighted)
                    
                    // Replace old action with new action
                    self.emptyStateView.emptyStateButton.removeTarget(self, action: #selector(self.showSearchTab), forControlEvents: .TouchUpInside)
                    self.emptyStateView.emptyStateButton.addTarget(self, action: #selector(self.reloadProducts), forControlEvents: .TouchUpInside)
                    self.emptyStateView.descriptionLabel.text = "\n\n" + "Whoops! There was an error loading new products."
                }
                else
                {
                    // User has browsed all items in Discover
                    self.emptyStateView.emptyStateButton.setTitle("Search Layers".uppercaseString, forState: .Normal)
                    self.emptyStateView.emptyStateButton.setTitle("Search Layers".uppercaseString, forState: .Highlighted)
                    
                    // Replace old action with new action
                    self.emptyStateView.emptyStateButton.removeTarget(self, action: #selector(self.reloadProducts), forControlEvents: .TouchUpInside)
                    self.emptyStateView.emptyStateButton.addTarget(self, action: #selector(self.showSearchTab), forControlEvents: .TouchUpInside)
                    
                    self.emptyStateView.descriptionLabel.text = "Wow! You've seen every item on Layers." + "\n\n" + "To keep browsing, try Search."
                }
                
                self.collectionView.hidden = true

                self.emptyStateView.hidden = false
            })
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
    
    func showSearchTab()
    {
        if let tabBarVc = tabBarController
        {
            tabBarVc.selectedIndex = 1
        }
    }
    
    func like(indexPath: NSIndexPath)
    {
//        if let productId = products?[safe: indexPath.row]?.productId
//        {
//            // Like Product
//        }
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ProductPostCell
        {
            if cell.likeButton.highlighted == false
            {
                cell.likeButton.highlighted = true
            }
            else
            {
                cell.likeButton.highlighted = false
            }
        }
    }
    
    func viewProductOnline(sender: UIButton)
    {
        let index = sender.tag
        
        if let outboundUrl = products?[safe: index]?.outboundUrl
        {
            showWebBrowser(outboundUrl)
        }
    }
    
    // MARK: SFSafariViewController
    
    func showWebBrowser(url: NSURL)
    {
        let webView = ProductWebViewController(URL: url)
        
        let navController = ProductWebNavigationController(rootViewController: webView)
        navController.setNavigationBarHidden(true, animated: false)
        navController.modalPresentationStyle = .OverFullScreen
        
        presentViewController(navController, animated: true, completion: nil)
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
        
        let cell: ProductPostCell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductPostCell", forIndexPath: indexPath) as! ProductPostCell
        
        if let items = products
        {
            let product: Product = items[indexPath.row]
            
            cell.productNameLabel.text = ""
            cell.priceLabel.text = ""
            
            // User Profile Image
            if let imageUrl = NSURL(string: "https://organicthemes.com/demo/profile/files/2012/12/profile_img.png")
            {
                cell.profilePictureImageView.sd_setImageWithURL(imageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                    
                    if image != nil && cacheType != .Memory
                    {
                        cell.profilePictureImageView.alpha = 0.0
                        
                        UIView.animateWithDuration(0.3, animations: {
                            cell.profilePictureImageView.alpha = 1.0
                        })
                    }
                })
            }
            
            // User's Full Name
            let fullName = "Blake Scott"
            
            let attributedNameString = NSMutableAttributedString(string: fullName, attributes: FontAttributes.headerTextAttributes)
            
            attributedNameString.appendAttributedString(NSAttributedString(string: " just bought this", attributes: FontAttributes.defaultTextAttributes))
            
            cell.userFullNameLabel.attributedText = attributedNameString
            
            // Timestamp
            let timestampDate = NSDate(timeIntervalSince1970: 1472951231)
                
            let timeStampString: String = timestampDate.shortTimeAgoSinceNow()
            
            cell.timestampLabel.attributedText = NSAttributedString(string: timeStampString, attributes: FontAttributes.boldBodyTextAttributes)
            
            // User Caption
            let userCaptionString: String = "This is the best overcoat I've bought. What do you guys think? Let me know in the comments!"
            
            cell.userCaptionLabel.attributedText = NSAttributedString(string: userCaptionString, attributes: FontAttributes.darkBodyTextAttributes)
            
//            // If no color filters are activated, use the first variant. Else, use the first variant with a matching color.
//            var variant: Variant?
//            
//            if let variants = product.variants
//            {
//                // Returns a variant that matches the color
//                if let matchingVariant = Variant.variantMatchingFilterColorsInVariants(variants)
//                {
//                    variant = matchingVariant
//                }
//            }
//
//            if variant == nil
//            {
//                if let firstVariant = product.variants?[safe: 0]
//                {
//                    variant = firstVariant
//                }
//            }
            
            // Set Images
        
            var productImages: Array<NSURL> = Array<NSURL>()
            
            // Append primary image
            if let primaryImageResolutions = product.images?.primaryImageUrls
            {
                if let imageIndex = primaryImageResolutions.indexOf({ $0.sizeName == "IPhone" })
                {
                    if let primaryImage: Image = primaryImageResolutions[safe: imageIndex]
                    {
                        if let imageUrl = primaryImage.url
                        {
                            productImages.append(imageUrl)
                        }
                    }
                }
            }
            
            // Append alternate images
            if let alternateImages = product.images?.alternateImages
            {
                for imageResolutions in alternateImages
                {
                    if let imageIndex = imageResolutions.indexOf({ $0.sizeName == "IPhone" })
                    {
                        if let altImage: Image = imageResolutions[safe: imageIndex]
                        {
                            if let imageUrl = altImage.url
                            {
                                productImages.append(imageUrl)
                            }
                        }
                    }
                }
            }
            
            cell.setImageElements(productImages)
            
            //Set Price
            var currentPrice: NSNumber?
            var retailPrice: NSNumber?
            
            if let currPrice = product.altPrice?.salePrice
            {
                currentPrice = currPrice
            }
            
            if let retail = product.price?.price
            {
                retailPrice = retail
            }
            
            cell.priceLabel.attributedText = NSAttributedString.priceStringWithRetailPrice(retailPrice, salePrice: currentPrice)
            
            if let brand = product.brand?.name,
                let unbrandedName = product.unbrandedName
            {
                let attributedString = NSMutableAttributedString(string: brand, attributes: FontAttributes.headerTextAttributes)
                
                attributedString.appendAttributedString(NSAttributedString(string: " \(unbrandedName)", attributes: FontAttributes.defaultTextAttributes))
                
                cell.productNameLabel.attributedText = attributedString
            }
            
            // Seperator
            cell.engagementSeperator.backgroundColor = Color.LightGray
            
            // Engagement
            
            // View Button
            cell.viewButton.setAttributedTitle(NSAttributedString(string: "View".uppercaseString, attributes: FontAttributes.buttonAttributes), forState: .Normal)
            
            cell.viewButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
            
            cell.viewButton.setImage(UIImage(named: "outbound-filled"), forState: .Normal)

            // Specifies which cell index the button was tapped at
            cell.viewButton.tag = indexPath.row
            
            cell.viewButton.addTarget(self, action: #selector(viewProductOnline(_:)), forControlEvents: .TouchUpInside)
            
            // Like Button
            let likeCount = 462
            
            let normalTextAttributes = [NSForegroundColorAttributeName: Color.GrayColor,
                                        NSFontAttributeName: Font.PrimaryFontRegular(size: 14.0)]
            
            let highlightedTextAttributes = [NSForegroundColorAttributeName: Color.PrimaryAppColor,
                                             NSFontAttributeName: Font.PrimaryFontRegular(size: 14.0)]
            
            cell.likeButton.setAttributedTitle(NSAttributedString(string: "\(likeCount)", attributes: normalTextAttributes), forState: .Normal)
            cell.likeButton.setAttributedTitle(NSAttributedString(string: "\(likeCount)", attributes: highlightedTextAttributes), forState: .Highlighted)

            cell.likeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell.likeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            
            cell.likeButton.setImage(UIImage(named: "heart"), forState: .Normal)
            cell.likeButton.setImage(UIImage(named: "heart-filled"), forState: .Highlighted)
            
            cell.likeButton.sizeToFit()
            
            // Comment Button
            cell.commentButton.setImage(UIImage(named: "chat-bubble"), forState: .Normal)
            cell.commentButton.setImage(UIImage(named: "chat-bubble-filled"), forState: .Highlighted)
        
            // Share Button
            cell.shareButton.setImage(UIImage(named: "share"), forState: .Normal)
            cell.shareButton.setImage(UIImage(named: "share-filled"), forState: .Highlighted)
        }
        
        return cell
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // Size for Product Cell
        let flowLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let width: CGFloat = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right)
        
        return CGSizeMake(width, 480.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
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
                        if let product = productCollection[indexPath.row] as Product?
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
