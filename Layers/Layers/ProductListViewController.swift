//
//  ProductListViewController.swift
//  Layers
//
//  Created by David Hodge on 9/10/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

protocol ProductListDelegate {
    func reloadData(_ activityType: UserActivity, completion: LRCompletionBlock?)
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
        collectionView.showsVerticalScrollIndicator = false
        
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
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            
                            self.collectionView.reloadData()
                        })
                    }
                }
            })
        }
    }
    
    // MARK: Networking

    // MARK: Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let products = products
        {
            return products.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductListCell", for: indexPath) as! ProductListCell
        
        cell.backgroundColor = Color.white
//        cell.nameLabel.preferredMaxLayoutWidth = 112.0
        
        if let product = products?[safe: (indexPath as NSIndexPath).row]
        {
            if let primaryImageUrl = product.primaryImageUrl(ImageSizeKey.Small)
            {
                cell.productImageView.sd_setImage(with: primaryImageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                    
                    if image != nil && cacheType != .memory
                    {
                        cell.productImageView.alpha = 0.0
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.productImageView.alpha = 1.0
                        })
                    }
                })
            }
            
            if let brand = product.brand?.name,
                let unbrandedName = product.unbrandedName
            {
                let attributedString = NSMutableAttributedString(string: brand, attributes: FontAttributes.headerTextAttributes)
                
                attributedString.append(NSAttributedString(string: " \(unbrandedName)", attributes: FontAttributes.defaultTextAttributes))
                
                cell.nameLabel.attributedText = attributedString
            }
            
            if let retailPrice = product.price?.price
            {
                if let salePrice = product.altPrice?.salePrice
                {
                    cell.priceLabel.attributedText = NSAttributedString.priceString(withRetailPrice: retailPrice, salePrice: salePrice)
                }
                else
                {
                    cell.priceLabel.attributedText = NSAttributedString.priceString(withRetailPrice: retailPrice, size: 16.0, strikethrough: false)
                }
            }
            
        }
        
        return cell
    }
    
    // MARK: Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let productId = products?[safe: (indexPath as NSIndexPath).row]?.productId
        {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            
            if let productVc = storyboard.instantiateViewController(withIdentifier: "ProductViewController") as? ProductViewController
            {
                productVc.productIdentifier = productId
                
                navigationController?.pushViewController(productVc, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItem(at: indexPath)
        {
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.HighlightedGrayColor
                
                if let productCell = cell as? ProductListCell
                {
                    productCell.productImageView.alpha = 0.5
                }
                
                }, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItem(at: indexPath)
        {
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.white
                
                if let productCell = cell as? ProductListCell
                {
                    productCell.productImageView.alpha = 1.0
                }
                
                }, completion: nil)
        }
    }
    
    // MARK: Collection View Delegate Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
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
