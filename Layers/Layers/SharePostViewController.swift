//
//  SharePostViewController.swift
//  Layers
//
//  Created by David Hodge on 10/17/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

private enum Section: Int
{
    case productPreview = 0, addCaption, count
}

class SharePostViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Share"
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(share))
        
        loadProduct()
    }
    
    // MARK: Networking
    func loadProduct()
    {
        if let productId = NewProduct.sharedProduct.productId
        {
            LRSessionManager.sharedManager.loadProduct(productId, completionHandler: { (success, error, response) -> Void in
                
                if success
                {
                    if let product = response as? Product
                    {
                        self.product = product
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            
                            self.collectionView.reloadData()
                        })
                    }
                }
                else
                {
                    log.error(error)
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        }
    }
    
    // MARK: Actions
    func share()
    {
        // Post new item
        
        // Clear New Product
        NewProduct.sharedProduct.reset()
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return Section.count.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let section = Section(rawValue: indexPath.section)
        {
            if section == .productPreview
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AltSimpleProductCell", for: indexPath) as! AltSimpleProductCell
                
                if let product = product
                {
                    if let url = product.primaryImageUrl(.Small)
                    {
                        cell.imageView.sd_setImage(with: url, completed: { (image, error, cacheType, imageUrl) -> Void in
                            
                            if image != nil && cacheType != .memory
                            {
                                cell.imageView.alpha = 0.0
                                
                                UIView.animate(withDuration: 0.3, animations: {
                                    cell.imageView.alpha = 1.0
                                })
                            }
                        })
                    }
                    
                    if let brand = product.brand?.name,
                        let unbrandedName = product.unbrandedName
                    {
                        let attributedString = NSMutableAttributedString(string: brand, attributes: FontAttributes.headerTextAttributes)
                        
                        attributedString.append(NSAttributedString(string: " \(unbrandedName)", attributes: FontAttributes.defaultTextAttributes))
                        
                        cell.productNameLabel.attributedText = attributedString
                    }
                    
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
                }
                // If Custom Product
                else
                {
                    if let productImage = NewProduct.sharedProduct.customProductImage
                    {
                        cell.imageView.image = productImage
                        
                        cell.productNameLabel.attributedText = NSAttributedString(string: "Custom Product", attributes: [:])
                    }
                }
                
                return cell
            }
            else if section == .addCaption
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPostCaptionCell", for: indexPath) as! AddPostCaptionCell
                
                cell.captionTextView.placeholder = "Add a caption..."
                
                cell.captionTextView.attributedText = NSAttributedString(string: "", attributes: [NSFontAttributeName: Font.PrimaryFontLight(size: 14.0), NSForegroundColorAttributeName: Color.GrayColor])
                
                if let usersImage = NewProduct.sharedProduct.userImage
                {
                    cell.imageView.image = usersImage
                }
                
                return cell
            }
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "AltSimpleProductCell", for: indexPath)
    }
    
    // MARK: Collection View Delegate

    
    // MARK: Collection View Delegate Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let width: CGFloat = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right)
        
        if let section = Section(rawValue: indexPath.section)
        {
            if section == .productPreview || section == .addCaption
            {
                return CGSize(width: width, height: 96.0)
            }
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if let section = Section(rawValue: section)
        {
            if section == .productPreview
            {
                return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            }
            else if section == .addCaption
            {
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 8.0
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
