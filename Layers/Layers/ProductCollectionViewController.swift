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

class ProductCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    private let kProductCellIdentfier = "ProductCell"

    @IBOutlet weak var collectionView: UICollectionView!
    
    var hidingNavBarManager: HidingNavigationBarManager?

    var products: Array<Product>?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "LAYERS"
        
        tabBarItem.title = "for you".uppercaseString
        tabBarItem.image = UIImage(named: "shirt")
        tabBarItem.image = UIImage(named: "shirt-filled")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "filter".uppercaseString,
                                                            style: .Plain,
                                                            target: self,
                                                            action: #selector(filter))
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: collectionView)
        hidingNavBarManager?.expansionResistance = 150

        if let tabBar = navigationController?.tabBarController?.tabBar {
            hidingNavBarManager?.manageBottomBar(tabBar)
        }
        
        //TEMP
        products = Array<Product>()

        let product = Product()
        product.imageURL = "http://i.imgur.com/DqZZiou.png?1"
        product.title = "Big Pony Polo"
        product.retailPrice = 8950
        product.salePrice = 4950
        products?.append(product)
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
    
    // MARK: Actions
    func filter()
    {
        print("Filter pressed")
    }
    
    // MARK: Collection View Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let items = products
        {
//            return items.count
            return 20
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let items = products
        {
//            let product: Product = items[indexPath.row]
            let product: Product = items[0]
            
            let cell: ProductCell = collectionView.dequeueReusableCellWithReuseIdentifier(kProductCellIdentfier, forIndexPath: indexPath) as! ProductCell
            
            cell.productImageView.image = nil
            cell.titleLabel.text = nil
            cell.priceLabel.text = nil
            
//            if let url = product.imageURL
//            {
//                cell.productImageView.sd_setImageWithURL(NSURL(string: url))
//            }
            cell.productImageView.image = UIImage(named: "blue-polo.png")
            
            cell.titleLabel.text = product.title
            
            cell.priceLabel.attributedText = NSAttributedString.priceStringWithRetailPrice(product.retailPrice, salePrice: product.salePrice)
            
            return cell
        }
        
        return collectionView.dequeueReusableCellWithReuseIdentifier(kProductCellIdentfier, forIndexPath: indexPath)
    }
    
    // MARK: Collection View Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("ShowProductViewController", sender: self)
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

//                let destinationVC: ProductViewController = segue.destinationViewController as! ProductViewController
//                destinationVC.productIdentifier = product.identifier

            }
            
            
        }
    }
}
