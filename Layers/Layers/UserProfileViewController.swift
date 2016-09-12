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
    case ProfileHeader = 0, UserProducts, _Count
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
        LRSessionManager.sharedManager.loadProduct(NSNumber(int: 512141429), completionHandler: { (success, error, response) -> Void in
            
            if success
            {
                if let product = response as? Product
                {
                    self.userProducts = [product, product, product]
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
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
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return Section._Count.rawValue
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let section = Section(rawValue: section)
        {
            if section == .ProfileHeader
            {
                return 1
            }
            else if section == .UserProducts
            {
                if let userProducts = userProducts
                {
                    return userProducts.count
                }
            }
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let section = Section(rawValue: indexPath.section)
        {
            if section == .ProfileHeader
            {
                if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfileHeaderCell", forIndexPath: indexPath) as? ProfileHeaderCell
                {
                    cell.profileImageView.image = nil
                    cell.followersCountLabel.text = nil
                    cell.salesCountLabel.text = nil
                    cell.purchasesCountLabel.text = nil
                    cell.fullNameLabel.text = nil
                    
                    // Dummy Data
                    if let userImageUrl = NSURL(string: "https://organicthemes.com/demo/profile/files/2012/12/profile_img.png")
                    {
                        cell.profileImageView.sd_setImageWithURL(userImageUrl, completed:nil)
                    }
                    
                    cell.fullNameLabel.attributedText = NSAttributedString(string: "David Hodge", attributes: FontAttributes.headerTextAttributes)
                    
                    cell.bio.attributedText = NSAttributedString(string: "I’m David, just a normal guy who really likes clothes. Oh, and I own a lot of J. Crew.", attributes: FontAttributes.bodyTextAttributes)
                    
                    cell.followersCountLabel.text = "423"
                    
                    cell.salesCountLabel.text = "39"
                    
                    cell.purchasesCountLabel.text = "14"
                    
                    let subheadingAttributes = [NSForegroundColorAttributeName: Color.GrayColor,
                                                NSFontAttributeName: Font.PrimaryFontRegular(size: 10.0),
                                                NSKernAttributeName: 0.7
                                                ]
                    
                    cell.followersLabel.attributedText = NSAttributedString(string: "followers", attributes: subheadingAttributes)
                    
                    cell.salesLabel.attributedText = NSAttributedString(string: "sales", attributes: subheadingAttributes)

                    cell.purchasesLabel.attributedText = NSAttributedString(string: "purchases", attributes: subheadingAttributes)

                    
                    return cell
                }
            }
            else if section == .UserProducts
            {
                if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserProductCell", forIndexPath: indexPath) as? UserProductCell
                {
                    cell.productImageView.image = nil
                    cell.brandLabel.text = nil
                    cell.productNameLabel.text = nil
                    
                    if let product = userProducts?[safe: indexPath.row]
                    {
                        if let imageUrl = product.primaryImageUrl(ImageSizeKey.Normal)
                        {
                            cell.productImageView.sd_setImageWithURL(imageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                                
                                if image != nil && cacheType != .Memory
                                {
                                    cell.productImageView.alpha = 0.0
                                    
                                    UIView.animateWithDuration(0.3, animations: {
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
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == Section.UserProducts.rawValue
        {
            if let productId = userProducts?[safe: indexPath.row]?.productId
            {
                let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                
                if let productVc = storyboard.instantiateViewControllerWithIdentifier("ProductViewController") as? ProductViewController
                {
                    productVc.productIdentifier = productId
                    
                    navigationController?.pushViewController(productVc, animated: true)
                }
            }
        }
    }
    
    // MARK: Collection View Delegate Flow Layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if let section = Section(rawValue: indexPath.section)
        {
            // Heights should be dynamic
            if section == .ProfileHeader
            {
                return CGSize(width: collectionView.bounds.size.width, height: 203.0)
            }
            else if section == .UserProducts
            {
                return CGSize(width: collectionView.bounds.size.width * 0.5 - 12, height: 217.0)
            }
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        if let section = Section(rawValue: section)
        {
            if section == .ProfileHeader
            {
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
            else if section == .UserProducts
            {
                return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            }
        }
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

}
