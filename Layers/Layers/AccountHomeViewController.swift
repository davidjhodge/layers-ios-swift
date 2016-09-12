//
//  AccountHomeViewController.swift
//  Layers
//
//  Created by David Hodge on 9/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

private enum Section: Int
{
    case ProfileHeader = 0, Activity, Other, _Count
}

enum UserActivity: Int
{
    case Purchases = 0, RecentlyViewed, Saved, MyComments, _Count
}

private enum OtherRow: Int
{
    case Settings = 0, ContactUs, _Count
}

class AccountHomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ProductListDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "Me"
        
        tabBarItem.title = "Me"
        tabBarItem.image = UIImage(named: "person")
        tabBarItem.selectedImage = UIImage(named: "person-filled")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Change status bar style to .LightContent
        navigationController?.navigationBar.barStyle = .Black
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.registerNib(UINib(nibName: "HeaderView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
    }
    
    // MARK: Collection View Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return Section._Count.rawValue
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let section = Section(rawValue: section)
        {
            switch section {
            case .ProfileHeader:
                
                return 1
                
            case .Activity:
                
                return UserActivity._Count.rawValue
                
            case .Other:
                
                return OtherRow._Count.rawValue
                
            default:
                break
            }
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let section = Section(rawValue: indexPath.section)
        {
            switch section {
            case .ProfileHeader:
                
                if indexPath.row == 0
                {
                    if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AccountHeaderCell", forIndexPath: indexPath) as? AccountHeaderCell
                    {
                        if let userImageUrl = NSURL(string: "https://organicthemes.com/demo/profile/files/2012/12/profile_img.png")
                        {
                            cell.profileImageView.sd_setImageWithURL(userImageUrl, completed:nil)
                        }
                        
                        cell.fullNameLabel.attributedText = NSAttributedString(string: "David Hodge", attributes: FontAttributes.largeHeaderTextAttributes)
                        
                        cell.ctaLabel.attributedText = NSAttributedString(string: "View Profile", attributes: FontAttributes.smallCtaAttributes)
                        
                        cell.backgroundColor = Color.whiteColor()
                        
                        return cell
                    }
                }
                
            case .Activity:
                
                if let row = UserActivity(rawValue: indexPath.row)
                {
                    if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BasicCollectionCell", forIndexPath: indexPath) as? BasicCollectionCell
                    {
                        let textAttributes = FontAttributes.defaultTextAttributes
                        
                        if row == .Purchases
                        {
                            cell.titleLabel.attributedText = NSAttributedString(string: "Purchases", attributes: textAttributes)
                        }
                        else if row == .RecentlyViewed
                        {
                            cell.titleLabel.attributedText = NSAttributedString(string: "Recently Viewed", attributes: textAttributes)

                        }
                        else if row == .Saved
                        {
                            cell.titleLabel.attributedText = NSAttributedString(string: "Saved Items", attributes: textAttributes)
                        }
                        else if row == .MyComments
                        {
                            cell.titleLabel.attributedText = NSAttributedString(string: "My Comments", attributes: textAttributes)
                        }
                        
                        cell.backgroundColor = Color.whiteColor()

                        return cell
                    }
                }
                
            case .Other:
                
                if let row = OtherRow(rawValue: indexPath.row)
                {
                    if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BasicCollectionCell", forIndexPath: indexPath) as? BasicCollectionCell
                    {
                        let textAttributes = FontAttributes.defaultTextAttributes
                        
                        if row == .Settings
                        {
                            cell.titleLabel.attributedText = NSAttributedString(string: "Settings", attributes: textAttributes)
                        }
                        else if row == .ContactUs
                        {
                            cell.titleLabel.attributedText = NSAttributedString(string: "Contact Us", attributes: textAttributes)
                        }
                        
                        cell.backgroundColor = Color.whiteColor()

                        return cell
                    }
                }
                
            default:
                break
            }
        }
    
        return collectionView.dequeueReusableCellWithReuseIdentifier("BasicCollectionCell", forIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader
        {
            if let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as? HeaderView
            {
                headerView.backgroundColor = Color.clearColor()
                
                let textAttributes = [NSFontAttributeName: Font.PrimaryFontRegular(size: 12.0),
                                      NSForegroundColorAttributeName: Color.GrayColor,
                                      NSKernAttributeName:0.7]
                
                if let section = Section(rawValue: indexPath.section)
                {
                    if section == .Activity
                    {
                        headerView.sectionTitleLabel.attributedText = NSAttributedString(string: "My Activity".uppercaseString, attributes: textAttributes)
                    }
                    else if section == .Other
                    {
                        headerView.sectionTitleLabel.attributedText = NSAttributedString(string: "Other".uppercaseString, attributes: textAttributes)
                    }
                    else
                    {
                        headerView.sectionTitleLabel.attributedText = NSAttributedString(string: "", attributes: nil)
                    }
                }
                
                return headerView
            }
        }
        
        return UICollectionReusableView()
    }
    
    // MARK: Collection View Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if let section = Section(rawValue: indexPath.section)
        {
            let storyboard = UIStoryboard(name: "Account", bundle: NSBundle.mainBundle())

            switch section {
            case .ProfileHeader:
                
                if indexPath.row == 0
                {
                    if let profileVc = storyboard.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController
                    {
                        navigationController?.pushViewController(profileVc, animated: true)
                    }
                }
                
            case .Activity:
                
                if let productListVc = storyboard.instantiateViewControllerWithIdentifier("ProductListViewController") as? ProductListViewController
                {
                    productListVc.delegate = self
                    
                    if let row = UserActivity(rawValue: indexPath.row)
                    {
                        if row == .Purchases
                        {
                            productListVc.title = "Purchases"
                            
                            productListVc.activityType = .Purchases
                        }
                        else if row == .RecentlyViewed
                        {
                            productListVc.title = "Recently Viewed"
                            
                            productListVc.activityType = .RecentlyViewed
                        }
                        else if row == .Saved
                        {
                            productListVc.title = "Saved Items"

                            productListVc.activityType = .Saved
                        }
                        else if row == .MyComments
                        {
                            productListVc.title = "My Comments"

                            productListVc.activityType = .MyComments
                        }
                    }
                    
                    navigationController?.pushViewController(productListVc, animated: true)
                }
                
            case .Other:
                
                if let row = OtherRow(rawValue: indexPath.row)
                {
                    if row == .Settings
                    {
                        if let settingsVc = storyboard.instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController
                        {
                            navigationController?.pushViewController(settingsVc, animated: true)
                        }
                    }
                    else if row == .ContactUs
                    {
                        if let contactVc = storyboard.instantiateViewControllerWithIdentifier("ContactUsViewController") as? ContactUsViewController
                        {
                            navigationController?.pushViewController(contactVc, animated: true)
                        }
                    }
                }
                
            default:
                break
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.HighlightedGrayColor
                
                if let headerCell = cell as? AccountHeaderCell
                {
                    headerCell.profileImageView.alpha = 0.5
                }
                
                }, completion: nil)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.whiteColor()
                
                if let headerCell = cell as? AccountHeaderCell
                {
                    headerCell.profileImageView.alpha = 1.0
                }
                
                }, completion: nil)
        }
    }
    
    // MARK: Collection View Flow Layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        {
            let viewWidth = view.bounds.size.width
            let leftInset = flowLayout.sectionInset.left
            let rightInset = flowLayout.sectionInset.right
            
            if let section = Section(rawValue: indexPath.section)
            {
                switch section {
                case .ProfileHeader:
                    
                    return CGSize(width: viewWidth - leftInset - rightInset, height: 96.0)
                    
                case .Activity:
                    
                    // Use code in .Other
                    return CGSize(width: viewWidth - leftInset - rightInset, height: 48.0)
                    
                case .Other:
                    
                    return CGSize(width: viewWidth - leftInset - rightInset, height: 48.0)
                    
                default:
                    break
                }
            }
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        // Width is ignored
        let ignoredWidth: CGFloat = 100
        
        if let section = Section(rawValue: section)
        {
            switch section {
            case .ProfileHeader:
                
                return CGSize(width: ignoredWidth, height: CGFloat(0.01))
                
            case .Activity:
                
                return CGSize(width: ignoredWidth, height: CGFloat(32.0))
                
            case .Other:
                
                return CGSize(width: ignoredWidth, height: CGFloat(32.0))
                
            default:
                break
            }
        }
        
        return CGSize(width: ignoredWidth, height: CGFloat(0.01))
    }
    
    // MARK: Product List Delegate
    func reloadData(row: UserActivity ,completion: LRCompletionBlock?) {
        
        if row == .Purchases
        {
            LRSessionManager.sharedManager.loadProduct(NSNumber(int: 512141429), completionHandler: { (success, error, response) -> Void in
                
                if let completion = completion
                {
                    completion(success: success, error: error, response: response)
                }
            })
        }
        else if row == .RecentlyViewed
        {
            LRSessionManager.sharedManager.loadProduct(NSNumber(int: 533783711), completionHandler: { (success, error, response) -> Void in
                
                if let completion = completion
                {
                    completion(success: success, error: error, response: response)
                }
            })
        }
        else if row == .Saved
        {
            LRSessionManager.sharedManager.loadProduct(NSNumber(int: 487066353), completionHandler: { (success, error, response) -> Void in
                
                if let completion = completion
                {
                    completion(success: success, error: error, response: response)
                }
            })
        }
        else if row == .MyComments
        {
            LRSessionManager.sharedManager.loadProduct(NSNumber(int: 505709302), completionHandler: { (success, error, response) -> Void in
                
                if let completion = completion
                {
                    completion(success: success, error: error, response: response)
                }
            })
        }
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
