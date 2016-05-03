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

import FBSDKLoginKit
import ObjectMapper

class ProductCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    private let kProductCellIdentfier = "ProductCell"

    @IBOutlet weak var collectionView: UICollectionView!
    
    var hidingNavBarManager: HidingNavigationBarManager?

    var products: Array<ProductResponse>?
    
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
                
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Up".uppercaseString, style: .Plain, target: self, action: #selector(createAccount))
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "filter".uppercaseString,
//                                                            style: .Plain,
//                                                            target: self,
//                                                            action: #selector(filter))
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filter"), style: .Plain, target: self, action: #selector(filter))
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: collectionView)
        hidingNavBarManager?.expansionResistance = 150

        if let tabBar = navigationController?.tabBarController?.tabBar {
            hidingNavBarManager?.manageBottomBar(tabBar)
        }
        
//        let product = Product()
//        product.imageURL = "http://i.imgur.com/DqZZiou.png?1"
//        product.title = "Big Pony Polo"
//        product.retailPrice = 8950
//        product.salePrice = 4950
//        products?.append(product)
        
        reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        hidingNavBarManager?.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        hidingNavBarManager?.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        hidingNavBarManager?.viewWillDisappear(animated)
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        hidingNavBarManager?.shouldScrollToTop()

        return true
    }
    
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        
//        return UIStatusBarStyle.LightContent
//        
//    }
    
    // MARK: Networking
    func reloadData()
    {
        LRSessionManager.sharedManager.loadProductCollection({ (success, error, response) -> Void in
            
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
    
    // MARK: Actions
    
    //TEMP
    func createAccount()
    {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        
        loginManager.logInWithReadPermissions(["public_profile", "user_friends", "email"], fromViewController: self, handler: {(result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            
            if error != nil
            {
                log.debug(error.localizedDescription)
            }
            else if result.isCancelled
            {
                log.debug("User cancelled Facebook Login")
            }
            else
            {
                log.debug("User successfully logged in with Facebook!")
                
//                let fbAccessToken = result.token.tokenString
                
                // Facebook token now exists and can be accessed at FBSDKAccessToken.currentAccessToken() 
                LRSessionManager.sharedManager.registerWithFacebook( { (success, error, result) -> Void in
                    
                    if success
                    {
                        log.debug("Facebook Registration Integration Complete.")
                        
                        let credential = LRSessionManager.sharedManager.credentialsProvider.identityId
                        
                        print(credential)
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
        })
    }
    
    func filter()
    {
        performSegueWithIdentifier("PresentModalFilterViewController", sender: self)
    }
    
    // MARK: Collection View Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let items = products
        {
            return items.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let items = products
        {
            let product: ProductResponse = items[indexPath.row]
            
            let cell: ProductCell = collectionView.dequeueReusableCellWithReuseIdentifier(kProductCellIdentfier, forIndexPath: indexPath) as! ProductCell
            
            // Use the first variant
            if let variant = product.variants?[0]
            {
                //Set Image View with first image
                if let firstImage = variant.images?[0]
                {
                    if let thumbnailUrl = firstImage.thumbnailUrl
                    {
                        cell.productImageView.sd_setImageWithURL(thumbnailUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                          
                            if image != nil && cacheType == .None
                            {
                                cell.productImageView.alpha = 0.0
                                
                                UIView.animateWithDuration(0.5, animations: {
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
    
    // MARK: Collection View Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("ShowProductViewController", sender: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let flowLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let width: CGFloat = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - 8) * 0.5
        
        return CGSizeMake(width, 226.0)
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
