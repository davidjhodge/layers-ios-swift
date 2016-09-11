//
//  ProductListViewController.swift
//  Layers
//
//  Created by David Hodge on 9/10/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

protocol ProductListDelegate {
    func reloadData(activityType: UserActivity, completion: LRCompletionBlock?)
}

class ProductListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var activityType: UserActivity?
    
    var delegate: ProductListDelegate?
    
    var products: Array<Product>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        
        // Set estimated item size of each collection view cell. This causes the collection view to query each cell for its size, so autolayout takes over
//        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
//        {
//            flowLayout.estimatedItemSize = CGSize(width: view.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right, height: 97.0)
//        }
        
        if let activity = activityType
        {
            delegate?.reloadData(activity, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let product = response as? Product
                    {
                        self.products = [product, product, product]
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.collectionView.reloadData()
                        })
                    }
                }
            })
        }
    }
    
    // MARK: Networking

    // MARK: Collection View Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let products = products
        {
            return products.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductListCell", forIndexPath: indexPath) as! ProductListCell
        
        cell.backgroundColor = Color.whiteColor()
//        cell.nameLabel.preferredMaxLayoutWidth = 112.0
        
        if let product = products?[safe: indexPath.row]
        {
            if let primaryImageUrl = product.primaryImageUrl(ImageSizeKey.Small)
            {
                cell.productImageView.sd_setImageWithURL(primaryImageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                    
                    if image != nil && cacheType != .Memory
                    {
                        cell.productImageView.alpha = 0.0
                        
                        UIView.animateWithDuration(0.3, animations: {
                            cell.productImageView.alpha = 1.0
                        })
                    }
                })
            }
            
            if let brand = product.brand?.name,
                let unbrandedName = product.unbrandedName
            {
                let attributedString = NSMutableAttributedString(string: brand, attributes: FontAttributes.headerTextAttributes)
                
                attributedString.appendAttributedString(NSAttributedString(string: " \(unbrandedName)", attributes: FontAttributes.defaultTextAttributes))
                
                cell.nameLabel.attributedText = attributedString
            }
            
            if let retailPrice = product.price?.price
            {
                if let salePrice = product.altPrice?.salePrice
                {
                    cell.priceLabel.attributedText = NSAttributedString.priceStringWithRetailPrice(retailPrice, salePrice: salePrice)
                }
                else
                {
                    cell.priceLabel.attributedText = NSAttributedString.priceStringWithRetailPrice(retailPrice, size: 16.0, strikethrough: false)
                }
            }
            
        }
        
        return cell
    }
    
    // MARK: Collection View Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if let productId = products?[safe: indexPath.row]?.productId
        {
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            
            if let productVc = storyboard.instantiateViewControllerWithIdentifier("ProductViewController") as? ProductViewController
            {
                productVc.productIdentifier = productId
                
                navigationController?.pushViewController(productVc, animated: true)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.HighlightedGrayColor
                
                if let productCell = cell as? ProductListCell
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
                
                if let productCell = cell as? ProductListCell
                {
                    productCell.productImageView.alpha = 1.0
                }
                
                }, completion: nil)
        }
    }
    
    // MARK: Collection View Delegate Flow Layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        {
            return CGSize(width: view.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right , height: 97.0)
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
