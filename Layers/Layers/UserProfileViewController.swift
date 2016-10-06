//
//  UserProfileViewController.swift
//  Layers
//
//  Created by David Hodge on 9/5/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

private enum Section: Int
{
    case profileHeader = 0, userProducts, _Count
}

class UserProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var collectionView: UICollectionView!
    
    var userProducts: Array<Product>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "dhodge416"
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        
        collectionView.alwaysBounceVertical = true
        
        collectionView.showsVerticalScrollIndicator = false

        reloadData()
    }
    
    func reloadData()
    {
        LRSessionManager.sharedManager.loadProduct(NSNumber(value: 512141429 as Int32), completionHandler: { (success, error, response) -> Void in
            
            if success
            {
                if let product = response as? Product
                {
                    self.userProducts = [product, product, product]
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        self.collectionView.reloadData()
                    })
                }
            }
            else
            {
                log.error(error)
            }
        })
    }
    
    // MARK: Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return Section._Count.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let section = Section(rawValue: section)
        {
            if section == .profileHeader
            {
                return 1
            }
            else if section == .userProducts
            {
                if let userProducts = userProducts
                {
                    return userProducts.count
                }
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let section = Section(rawValue: (indexPath as NSIndexPath).section)
        {
            if section == .profileHeader
            {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileHeaderCell", for: indexPath) as? ProfileHeaderCell
                {
                    cell.profileImageView.image = nil
                    cell.followersCountLabel.text = nil
                    cell.salesCountLabel.text = nil
                    cell.purchasesCountLabel.text = nil
                    cell.fullNameLabel.text = nil
                    
                    // Dummy Data
                    if let userImageUrl = URL(string: "https://organicthemes.com/demo/profile/files/2012/12/profile_img.png")
                    {
                        cell.profileImageView.sd_setImage(with: userImageUrl, completed:nil)
                    }
                    
                    cell.fullNameLabel.attributedText = NSAttributedString(string: "David Hodge", attributes: FontAttributes.headerTextAttributes)
                    
                    cell.bio.attributedText = NSAttributedString(string: "I’m David, just a normal guy who really likes clothes. Oh, and I own a lot of J. Crew.", attributes: FontAttributes.bodyTextAttributes)
                    
                    cell.followersCountLabel.text = "423"
                    
                    cell.salesCountLabel.text = "39"
                    
                    cell.purchasesCountLabel.text = "14"
                    
                    let subheadingAttributes = [NSForegroundColorAttributeName: Color.GrayColor,
                                                NSFontAttributeName: Font.PrimaryFontRegular(size: 10.0),
                                                NSKernAttributeName: 0.7
                                                ] as [String : Any]
                    
                    cell.followersLabel.attributedText = NSAttributedString(string: "followers", attributes: subheadingAttributes)
                    
                    cell.salesLabel.attributedText = NSAttributedString(string: "sales", attributes: subheadingAttributes)

                    cell.purchasesLabel.attributedText = NSAttributedString(string: "purchases", attributes: subheadingAttributes)

                    
                    return cell
                }
            }
            else if section == .userProducts
            {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserProductCell", for: indexPath) as? UserProductCell
                {
                    cell.productImageView.image = nil
                    cell.brandLabel.text = nil
                    cell.productNameLabel.text = nil
                    
                    if let product = userProducts?[safe: (indexPath as NSIndexPath).row]
                    {
                        if let imageUrl = product.primaryImageUrl(ImageSizeKey.Normal)
                        {
                            cell.productImageView.sd_setImage(with: imageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                                
                                if image != nil && cacheType != .memory
                                {
                                    cell.productImageView.alpha = 0.0
                                    
                                    UIView.animate(withDuration: 0.3, animations: {
                                        cell.productImageView.alpha = 1.0
                                    })
                                }
                            })
                        }
                        
                        if let brand = product.brand?.name
                        {
                            cell.brandLabel.attributedText = NSAttributedString(string: brand, attributes: FontAttributes.headerTextAttributes)
                        }
                        
                        if let productName = product.unbrandedName
                        {
                            cell.productNameLabel.attributedText = NSAttributedString(string: productName, attributes: FontAttributes.bodyTextAttributes)
                        }
                    }
                    
                    return cell
                }
            }
        }


        return UICollectionViewCell()
    }
    
    // MARK: Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == Section.userProducts.rawValue
        {
            if let productId = userProducts?[safe: (indexPath as NSIndexPath).row]?.productId
            {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                
                if let productVc = storyboard.instantiateViewController(withIdentifier: "ProductViewController") as? ProductViewController
                {
                    productVc.productIdentifier = productId
                    
                    navigationController?.pushViewController(productVc, animated: true)
                }
            }
        }
    }
    
    // MARK: Collection View Delegate Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let section = Section(rawValue: (indexPath as NSIndexPath).section)
        {
            // Heights should be dynamic
            if section == .profileHeader
            {
                return CGSize(width: collectionView.bounds.size.width, height: 203.0)
            }
            else if section == .userProducts
            {
                return CGSize(width: collectionView.bounds.size.width * 0.5 - 12, height: 217.0)
            }
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if let section = Section(rawValue: section)
        {
            if section == .profileHeader
            {
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
            else if section == .userProducts
            {
                return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            }
        }
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

}
