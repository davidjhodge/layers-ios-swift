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
import IDMPhotoBrowser

class DiscoverViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PaginatedImageViewDelegate
{
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewBottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emptyStateView: EmptyStateView!
    
    @IBOutlet weak var emptyStateButton: UIButton!

    var products: Array<Product>?
    
    var currentPage: Int?
    
    var refreshControl: UIRefreshControl?
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let titleLabel = UILabel(frame: CGRect(x: 0,y: 0,width: 28,height: 80))
        titleLabel.attributedText = NSAttributedString(string: "Layers".uppercased(), attributes: [NSForegroundColorAttributeName: Color.white,
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
        navigationController?.navigationBar.barStyle = .black
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = Color.lightGray
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl?.layer.zPosition = -1
        collectionView.addSubview(refreshControl!)
        
        // Flow Layout
        let customLayout = NHAlignmentFlowLayout()
        customLayout.scrollDirection = .vertical
        customLayout.alignment = .topLeftAligned
        customLayout.minimumLineSpacing = 8.0
        customLayout.minimumInteritemSpacing = 8.0
        customLayout.sectionInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        collectionView.collectionViewLayout = customLayout
        
        emptyStateButton.setBackgroundColor(Color.NeonBlueColor, forState: UIControlState())
        emptyStateButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .highlighted)
        
        emptyStateButton.addTarget(self, action: #selector(showSearchTab), for: .touchUpInside)
        
        spinner.hidesWhenStopped = true
        spinner.isHidden = true
        spinner.color = Color.gray
        view.addSubview(spinner)
                
        reloadProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !LRSessionManager.sharedManager.hasSeenDiscoverPopup()
        {
            if let popupView = Bundle.main.loadNibNamed("DiscoverPopup", owner: self, options: nil)?[0] as? DiscoverPopupView
            {
                let discoverPopup = KLCPopup(contentView: popupView, showType: .bounceIn, dismissType: .bounceOut, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: true)
                
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if self.products == nil || self.products?.count == 0
        {
            self.spinner.startAnimating()
        }
        
        if emptyStateView.isHidden == false
        {
            toggleErrorState(true, error: false)
        }
        
        LRSessionManager.sharedManager.loadProduct(NSNumber(value: 512141429 as Int32), completionHandler: { (success, error, response) -> Void in
            
            if success
            {
                if let product = response as? Product
                {
                    self.products = [product]
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        self.collectionView.reloadData()
                    })
                }
            }
            else
            {
                log.error(error)
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                self.refreshControl?.endRefreshing()
                
                self.spinner.stopAnimating()
            })
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        LRSessionManager.sharedManager.loadDiscoverProducts({ (success, error, response) -> Void in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if success
            {
                if let newProducts: Array<Product> = response as? Array<Product>
                {
                    // If this is a response for page 2 or greater
                    self.products?.append(contentsOf: newProducts)
                    
                    // Update UI
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        let topOffset = self.collectionView.contentOffset.y
                        
                        //Insert new products
                        CATransaction.begin()
                        CATransaction.setDisableActions(true)
                        
                        self.collectionView.performBatchUpdates({ () -> Void in
                            
                            var indexPaths = Array<IndexPath>()
                            
                            // (Page - 1) represents the first index we want to insert into
                            if let products = self.products
                            {
                                let index: Int = products.count - newProducts.count
                                
                                // When less items than the productCollectionPageSize are returned, newProducts.count ensures we only try to insert the number of products we have. This avoids an indexOutOfBounds error
                                for i in index...index+newProducts.count-1
                                {
                                    indexPaths.append(IndexPath(row: i, section: 0))
                                }
                                
                                self.collectionView.insertItems(at: indexPaths)
                                
                            }
                            }, completion: { (finished) -> Void in
                                
                                // Set correct content offset
                                self.collectionView.contentOffset = CGPoint(x: 0, y: topOffset)
                                CATransaction.commit()
                        })
                    })
                }
            }
            else
            {
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        })
    }
    
    func toggleErrorState(_ hidden: Bool, error: Bool)
    {
        if hidden == true
        {
            DispatchQueue.main.async(execute: { () -> Void in
                
                self.collectionView.isHidden = false
                
                self.emptyStateView.isHidden = true
            })
        }
        else
        {
            DispatchQueue.main.async(execute: { () -> Void in
                
                if error
                {
                    self.emptyStateView.emptyStateButton.setTitle("Retry".uppercased(), for: UIControlState())
                    self.emptyStateView.emptyStateButton.setTitle("Retry".uppercased(), for: .highlighted)
                    
                    // Replace old action with new action
                    self.emptyStateView.emptyStateButton.removeTarget(self, action: #selector(self.showSearchTab), for: .touchUpInside)
                    self.emptyStateView.emptyStateButton.addTarget(self, action: #selector(self.reloadProducts), for: .touchUpInside)
                    self.emptyStateView.descriptionLabel.text = "\n\n" + "Whoops! There was an error loading new products."
                }
                else
                {
                    // User has browsed all items in Discover
                    self.emptyStateView.emptyStateButton.setTitle("Search Layers".uppercased(), for: UIControlState())
                    self.emptyStateView.emptyStateButton.setTitle("Search Layers".uppercased(), for: .highlighted)
                    
                    // Replace old action with new action
                    self.emptyStateView.emptyStateButton.removeTarget(self, action: #selector(self.reloadProducts), for: .touchUpInside)
                    self.emptyStateView.emptyStateButton.addTarget(self, action: #selector(self.showSearchTab), for: .touchUpInside)
                    
                    self.emptyStateView.descriptionLabel.text = "Wow! You've seen every item on Layers." + "\n\n" + "To keep browsing, try Search."
                }
                
                self.collectionView.isHidden = true

                self.emptyStateView.isHidden = false
            })
        }
    }
    
    func hardReloadCollectionView()
    {
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.collectionView.reloadData()
            
            self.collectionView.setContentOffset(CGPoint.zero, animated: false)
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
    
    func like(_ indexPath: IndexPath)
    {
//        if let productId = products?[safe: indexPath.row]?.productId
//        {
//            // Like Product
//        }
        if let cell = collectionView.cellForItem(at: indexPath) as? ProductPostCell
        {
            if cell.likeButton.isHighlighted == false
            {
                cell.likeButton.isHighlighted = true
            }
            else
            {
                cell.likeButton.isHighlighted = false
            }
        }
    }
    
    func viewProductOnline(_ sender: UIButton)
    {
        let index = sender.tag
        
        if let outboundUrl = products?[safe: index]?.outboundUrl
        {
            showWebBrowser(outboundUrl)
        }
    }
    
    // MARK: Paginated Image View Delegate
    func showPhotoFullscreen(_ imageView: UIImageView, photos: Array<URL>, selectedIndex: Int)
    {
        // Analytics
//        if let index = selectedCollectionIndex
//        {
//            if let product = products[safe: index]
//            {
//                if let productId = product.productId,
//                    let productName = product.brandedName,
//                    let category = product.categories?[safe: 0]?.name
//                {
//                    FBSDKAppEvents.logEvent("Product Page Photo Taps", parameters: ["Product ID":productId, "Product Name":productName, "Category Name":category])
//                }
//            }
//        }
        
        // Show Photo
        let photoBrowser = IDMPhotoBrowser(photoURLs: photos, animatedFrom: imageView)
        
        photoBrowser?.scaleImage = imageView.image
        
        photoBrowser?.view.tintColor = Color.white
        
        photoBrowser?.displayArrowButton = false
        
        photoBrowser?.displayCounterLabel = false
        
//        photoBrowser?.forceHideStatusBar = true
        
        photoBrowser?.useWhiteBackgroundColor = false
        
        photoBrowser?.usePopAnimation = true
        
        photoBrowser?.displayActionButton = false
        
        // Show Done Button
        photoBrowser?.displayDoneButton = true
        
        photoBrowser?.setInitialPageIndex(UInt(selectedIndex))
        
        present(photoBrowser!, animated: true, completion: nil)
    }
    
    // MARK: SFSafariViewController
    
    func showWebBrowser(_ url: URL)
    {
        let webView = ProductWebViewController(url: url)
        
        let navController = ProductWebNavigationController(rootViewController: webView)
        navController.setNavigationBarHidden(true, animated: false)
        navController.modalPresentationStyle = .overFullScreen
        
        present(navController, animated: true, completion: nil)
    }

    // MARK: Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let items = products , items.count > 0
        {
            return items.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ProductPostCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductPostCell", for: indexPath) as! ProductPostCell
        
        if let items = products
        {
            let product: Product = items[(indexPath as NSIndexPath).row]
            
            cell.productNameLabel.text = ""
            cell.priceLabel.text = ""
            
            cell.delegate = self
            
            // User Profile Image
            if let imageUrl = URL(string: "https://organicthemes.com/demo/profile/files/2012/12/profile_img.png")
            {
                cell.profilePictureImageView.sd_setImage(with: imageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                    
                    if image != nil && cacheType != .memory
                    {
                        cell.profilePictureImageView.alpha = 0.0
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.profilePictureImageView.alpha = 1.0
                        })
                    }
                })
            }
            
            // User's Full Name
            let fullName = "Blake Scott"
            
            let attributedNameString = NSMutableAttributedString(string: fullName, attributes: FontAttributes.headerTextAttributes)
            
            attributedNameString.append(NSAttributedString(string: " just bought this", attributes: FontAttributes.defaultTextAttributes))
            
            cell.userFullNameLabel.attributedText = attributedNameString
            
            // Timestamp
            let timestampDate = Date(timeIntervalSince1970: 1472951231)
                
            let timeStampString: String = (timestampDate as NSDate).shortTimeAgoSinceNow().lowercased()
            
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
        
            var productImages: Array<URL> = Array<URL>()
            
            // Append primary image
            if let primaryImageResolutions = product.images?.primaryImageUrls
            {
                if let imageIndex = primaryImageResolutions.index(where: { $0.sizeName == "IPhone" })
                {
                    if let primaryImage: Image = primaryImageResolutions[safe: imageIndex]
                    {
                        if let imageUrl = primaryImage.url
                        {
                            productImages.append(imageUrl as URL)
                        }
                    }
                }
            }
            
            // Append alternate images
            if let alternateImages = product.images?.alternateImages
            {
                for imageResolutions in alternateImages
                {
                    if let imageIndex = imageResolutions.index(where: { $0.sizeName == "IPhone" })
                    {
                        if let altImage: Image = imageResolutions[safe: imageIndex]
                        {
                            if let imageUrl = altImage.url
                            {
                                productImages.append(imageUrl as URL)
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
            
            cell.priceLabel.attributedText = NSAttributedString.priceString(withRetailPrice: retailPrice, salePrice: currentPrice)
            
            if let brand = product.brand?.name,
                let unbrandedName = product.unbrandedName
            {
                let attributedString = NSMutableAttributedString(string: brand, attributes: FontAttributes.headerTextAttributes)
                
                attributedString.append(NSAttributedString(string: " \(unbrandedName)", attributes: FontAttributes.defaultTextAttributes))
                
                cell.productNameLabel.attributedText = attributedString
            }
            
            // Seperator
            cell.engagementSeperator.backgroundColor = Color.LightGray
            
            // Engagement
            
            // View Button
            cell.viewButton.setAttributedTitle(NSAttributedString(string: "View".uppercased(), attributes: FontAttributes.buttonAttributes), for: UIControlState())
            
//            cell.viewButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
//            
//            cell.viewButton.setImage(UIImage(named: "outbound-filled"), for: UIControlState())
            
            cell.viewButton.layer.borderColor = Color.PrimaryAppColor.cgColor
            
            cell.viewButton.layer.cornerRadius = 4.0
            
            cell.viewButton.layer.borderWidth = 1.5

            // Specifies which cell index the button was tapped at
            cell.viewButton.tag = (indexPath as NSIndexPath).row
            
            cell.viewButton.addTarget(self, action: #selector(viewProductOnline(_:)), for: .touchUpInside)
            
            // Like Button
            let likeCount = 462
            
            let normalTextAttributes = [NSForegroundColorAttributeName: Color.GrayColor,
                                        NSFontAttributeName: Font.PrimaryFontRegular(size: 14.0)]
            
            let highlightedTextAttributes = [NSForegroundColorAttributeName: Color.PrimaryAppColor,
                                             NSFontAttributeName: Font.PrimaryFontRegular(size: 14.0)]
            
            cell.likeButton.setAttributedTitle(NSAttributedString(string: "\(likeCount)", attributes: normalTextAttributes), for: UIControlState())
            cell.likeButton.setAttributedTitle(NSAttributedString(string: "\(likeCount)", attributes: highlightedTextAttributes), for: .highlighted)

            cell.likeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell.likeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            
            cell.likeButton.setImage(UIImage(named: "heart"), for: UIControlState())
            cell.likeButton.setImage(UIImage(named: "heart-filled"), for: .highlighted)
            
            cell.likeButton.sizeToFit()
            
            // Comment Button
            cell.commentButton.setImage(UIImage(named: "chat-bubble"), for: UIControlState())
            cell.commentButton.setImage(UIImage(named: "chat-bubble-filled"), for: .highlighted)
        
            // Share Button
            cell.shareButton.setImage(UIImage(named: "share"), for: UIControlState())
            cell.shareButton.setImage(UIImage(named: "share-filled"), for: .highlighted)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let products = products
        {
            // Insert next page of items as we near the end of the current list
            if (indexPath as NSIndexPath).row == products.count - 4
            {
                // If last page returned a full list of products, it's highly likely the next page is not empty. This is not perfect, but will reduce unnecessary API calls
                loadMoreProducts()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Size for Product Cell
        let flowLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let width: CGFloat = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right)
        
        return CGSize(width: width, height: 480.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProductViewController"
        {
            if segue.destination is ProductViewController
            {
//                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)

                //Selected Product Index
                if let indexPath = sender as? IndexPath
                {
                    if let productCollection = products
                    {
                        if let product = productCollection[(indexPath as NSIndexPath).row] as Product?
                        {
                            if let destinationVC = segue.destination as? ProductViewController
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
