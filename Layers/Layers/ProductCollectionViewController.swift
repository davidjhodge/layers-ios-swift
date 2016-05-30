//
//  ProductCollectionViewController.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import HidingNavigationBar

class ProductCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FilterDelegate
{
    private let kProductCellIdentfier = "ProductCell"

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewBottomLayoutConstraint: NSLayoutConstraint!
    
//    var hidingNavBarManager: HidingNavigationBarManager?

    var products: Array<ProductResponse>?
    
    var currentPage: Int?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let titleLabel = UILabel(frame: CGRectMake(0,0,28,80))
        titleLabel.attributedText = NSAttributedString(string: "Layers".uppercaseString, attributes: [NSForegroundColorAttributeName: Color.whiteColor(),
            NSFontAttributeName: Font.CharterBold(size: 20.0),
            NSKernAttributeName: 1.0]
        )
        navigationItem.titleView = titleLabel
        
        tabBarItem.title = "for you".uppercaseString
        tabBarItem.image = UIImage(named: "shirt")
        tabBarItem.image = UIImage(named: "shirt-filled")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(search))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "filter"), style: .Plain, target: self, action: #selector(filter))
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
//        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: collectionView)
//        hidingNavBarManager?.expansionResistance = 150
//
//        if let tabBar = navigationController?.tabBarController?.tabBar {
//            hidingNavBarManager?.manageBottomBar(tabBar)
//        }
        
        currentPage = 1
        
        reloadData(currentPage!)
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        hidingNavBarManager?.viewWillAppear(animated)
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        hidingNavBarManager?.viewDidLayoutSubviews()
        
        if let tabBar = navigationController?.tabBarController?.tabBar {
        collectionViewBottomLayoutConstraint.constant = (-1 * tabBar.bounds.size.height) + 8
        }
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        hidingNavBarManager?.viewWillDisappear(animated)
//    }
//    
//    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
//        hidingNavBarManager?.shouldScrollToTop()
//
//        return true
//    }
    
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        
//        return UIStatusBarStyle.LightContent
//        
//    }
    
    // MARK: Networking
    func reloadData(page: Int)
    {
        if page == 0 || page > 0
        {
            LRSessionManager.sharedManager.loadProductCollection(page, completionHandler: { (success, error, response) -> Void in
                
                if success
                {
                    if let productsResponse = response as? Array<ProductResponse>
                    {
                        self.products = productsResponse
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.collectionView.reloadData()
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
        else
        {
            let alert = UIAlertController(title: "Page not specified.", message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Actions
    func search()
    {
        performSegueWithIdentifier("ShowSearchViewController", sender: self)
    }
    
    func filter()
    {
        performSegueWithIdentifier("PresentModalFilterViewController", sender: self)
    }
    
    // MARK: Filter Delegate
    func didUpdateFilter()
    {
        currentPage = 1
        
        reloadData(currentPage!)
    }
    
    // MARK: DPLProductDetailViewController
//    func configureWithDeepLink(deepLink: DPLDeepLink!) {
//        
//        if let key = deepLink.routeParameters["product_id"] as? String
//        {
//            if let productId = Int(key)
//            {
//                performSegueWithIdentifier("ShowProductViewControllerFromDeepLink", sender: productId)
//            }
//        }
//    }
    
    // MARK: Collection View Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let items = products where items.count > 0
        {
            // + 1 for Spinner
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
            
            // Use the first variant
            if let variant = product.variants?[0]
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
                if let firstSize = variant.sizes?[0]
                {
                    if let priceInfo = firstSize.prices?[0]
                    {
                        var currentPrice: NSNumber?
                        var retailPrice: NSNumber?
                        
                        if let currPrice = priceInfo.price
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
            
            if let brand = product.brandName
            {
                cell.brandLabel.text = brand.uppercaseString
            }
            
            return cell
        }
        
        return collectionView.dequeueReusableCellWithReuseIdentifier(kProductCellIdentfier, forIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if let products = products
        {
            // Insert next page of items as we near the end of the current list
            if indexPath.row == products.count - 2
            {
                // Get next page of results
                if let page = currentPage
                {
                    currentPage = page + 1
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    
                    LRSessionManager.sharedManager.loadProductCollection(currentPage!, completionHandler: { (success, error, response) -> Void in
                        
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

                        if success
                        {
                            if let newProducts: Array<ProductResponse> = response as? Array<ProductResponse>
                            {
                                self.products?.appendContentsOf(newProducts)
                                
                                // Update UI
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                  
                                    //Insert new products
                                    collectionView.performBatchUpdates({ () -> Void in
                                        
                                        var indexPaths = Array<NSIndexPath>()

                                        let index: Int = page * productCollectionPageSize
                                        
                                        for i in index...index+productCollectionPageSize-1
                                        {
                                            indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
                                        }
                                        
                                        collectionView.insertItemsAtIndexPaths(indexPaths)
                                        
                                        }, completion: nil)
                                })
                            }
                        }
                        else
                        {
                            if let loadingCell = collectionView.cellForItemAtIndexPath(                        NSIndexPath(forItem: products.count, inSection: 0)) as? LoadingCell
                            {
                                loadingCell.spinner.stopAnimating()
                            }
                            
                            let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    })
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
//        else if segue.identifier == "ShowProductViewControllerFromDeepLink"
//        {
//            if let destinationVC = segue.destinationViewController as? ProductViewController
//            {
//                if let productId = sender as? Int
//                {
//                    destinationVC.productIdentifier = productId
//                }
//            }
//        }
        else if segue.identifier == "PresentModalFilterViewController"
        {
            if let destinationNav = segue.destinationViewController as? UINavigationController
            {
                if let destinationVc = destinationNav.viewControllers[safe: 0] as? FilterViewController
                {
                    destinationVc.delegate = self
                }
            }

        }
    }
}
