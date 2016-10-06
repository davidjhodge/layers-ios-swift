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
    case profileHeader = 0, activity, other, _Count
}

enum UserActivity: Int
{
    case purchases = 0, recentlyViewed, saved, myComments, _Count
}

private enum OtherRow: Int
{
    case settings = 0, contactUs, _Count
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
        navigationController?.navigationBar.barStyle = .black
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.register(UINib(nibName: "HeaderView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
    }
    
    // MARK: Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return Section._Count.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let section = Section(rawValue: section)
        {
            switch section {
            case .profileHeader:
                
                return 1
                
            case .activity:
                
                return UserActivity._Count.rawValue
                
            case .other:
                
                return OtherRow._Count.rawValue
                
            default:
                break
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let section = Section(rawValue: (indexPath as NSIndexPath).section)
        {
            switch section {
            case .profileHeader:
                
                if (indexPath as NSIndexPath).row == 0
                {
                    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccountHeaderCell", for: indexPath) as? AccountHeaderCell
                    {
                        if let userImageUrl = URL(string: "https://organicthemes.com/demo/profile/files/2012/12/profile_img.png")
                        {
                            cell.profileImageView.sd_setImage(with: userImageUrl, completed:nil)
                        }
                        
                        cell.fullNameLabel.attributedText = NSAttributedString(string: "David Hodge", attributes: FontAttributes.largeHeaderTextAttributes)
                        
                        cell.ctaLabel.attributedText = NSAttributedString(string: "View Profile", attributes: FontAttributes.smallCtaAttributes)
                        
                        cell.backgroundColor = Color.white
                        
                        return cell
                    }
                }
                
            case .activity:
                
                if let row = UserActivity(rawValue: (indexPath as NSIndexPath).row)
                {
                    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BasicCollectionCell", for: indexPath) as? BasicCollectionCell
                    {
                        let textAttributes = FontAttributes.defaultTextAttributes
                        
                        if row == .purchases
                        {
                            cell.titleLabel.attributedText = NSAttributedString(string: "Purchases", attributes: textAttributes)
                        }
                        else if row == .recentlyViewed
                        {
                            cell.titleLabel.attributedText = NSAttributedString(string: "Recently Viewed", attributes: textAttributes)

                        }
                        else if row == .saved
                        {
                            cell.titleLabel.attributedText = NSAttributedString(string: "Saved Items", attributes: textAttributes)
                        }
                        else if row == .myComments
                        {
                            cell.titleLabel.attributedText = NSAttributedString(string: "My Comments", attributes: textAttributes)
                        }
                        
                        cell.backgroundColor = Color.white

                        return cell
                    }
                }
                
            case .other:
                
                if let row = OtherRow(rawValue: (indexPath as NSIndexPath).row)
                {
                    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BasicCollectionCell", for: indexPath) as? BasicCollectionCell
                    {
                        let textAttributes = FontAttributes.defaultTextAttributes
                        
                        if row == .settings
                        {
                            cell.titleLabel.attributedText = NSAttributedString(string: "Settings", attributes: textAttributes)
                        }
                        else if row == .contactUs
                        {
                            cell.titleLabel.attributedText = NSAttributedString(string: "Contact Us", attributes: textAttributes)
                        }
                        
                        cell.backgroundColor = Color.white

                        return cell
                    }
                }
                
            default:
                break
            }
        }
    
        return collectionView.dequeueReusableCell(withReuseIdentifier: "BasicCollectionCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader
        {
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as? HeaderView
            {
                headerView.backgroundColor = Color.clear
                
                let textAttributes = [NSFontAttributeName: Font.PrimaryFontRegular(size: 12.0),
                                      NSForegroundColorAttributeName: Color.GrayColor,
                                      NSKernAttributeName:0.7] as [String : Any]
                
                if let section = Section(rawValue: (indexPath as NSIndexPath).section)
                {
                    if section == .activity
                    {
                        headerView.sectionTitleLabel.attributedText = NSAttributedString(string: "My Activity".uppercased(), attributes: textAttributes)
                    }
                    else if section == .other
                    {
                        headerView.sectionTitleLabel.attributedText = NSAttributedString(string: "Other".uppercased(), attributes: textAttributes)
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let section = Section(rawValue: (indexPath as NSIndexPath).section)
        {
            let storyboard = UIStoryboard(name: "Account", bundle: Bundle.main)

            switch section {
            case .profileHeader:
                
                if (indexPath as NSIndexPath).row == 0
                {
                    if let profileVc = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController
                    {
                        navigationController?.pushViewController(profileVc, animated: true)
                    }
                }
                
            case .activity:
                
                if let productListVc = storyboard.instantiateViewController(withIdentifier: "ProductListViewController") as? ProductListViewController
                {
                    productListVc.delegate = self
                    
                    if let row = UserActivity(rawValue: (indexPath as NSIndexPath).row)
                    {
                        if row == .purchases
                        {
                            productListVc.title = "Purchases"
                            
                            productListVc.activityType = .purchases
                        }
                        else if row == .recentlyViewed
                        {
                            productListVc.title = "Recently Viewed"
                            
                            productListVc.activityType = .recentlyViewed
                        }
                        else if row == .saved
                        {
                            productListVc.title = "Saved Items"

                            productListVc.activityType = .saved
                        }
                        else if row == .myComments
                        {
                            productListVc.title = "My Comments"

                            productListVc.activityType = .myComments
                        }
                    }
                    
                    navigationController?.pushViewController(productListVc, animated: true)
                }
                
            case .other:
                
                if let row = OtherRow(rawValue: (indexPath as NSIndexPath).row)
                {
                    if row == .settings
                    {
                        if let settingsVc = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
                        {
                            navigationController?.pushViewController(settingsVc, animated: true)
                        }
                    }
                    else if row == .contactUs
                    {
                        if let contactVc = storyboard.instantiateViewController(withIdentifier: "ContactUsViewController") as? ContactUsViewController
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
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItem(at: indexPath)
        {
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.HighlightedGrayColor
                
                if let headerCell = cell as? AccountHeaderCell
                {
                    headerCell.profileImageView.alpha = 0.5
                }
                
                }, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItem(at: indexPath)
        {
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.white
                
                if let headerCell = cell as? AccountHeaderCell
                {
                    headerCell.profileImageView.alpha = 1.0
                }
                
                }, completion: nil)
        }
    }
    
    // MARK: Collection View Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        {
            let viewWidth = view.bounds.size.width
            let leftInset = flowLayout.sectionInset.left
            let rightInset = flowLayout.sectionInset.right
            
            if let section = Section(rawValue: (indexPath as NSIndexPath).section)
            {
                switch section {
                case .profileHeader:
                    
                    return CGSize(width: viewWidth - leftInset - rightInset, height: 96.0)
                    
                case .activity:
                    
                    // Use code in .Other
                    return CGSize(width: viewWidth - leftInset - rightInset, height: 48.0)
                    
                case .other:
                    
                    return CGSize(width: viewWidth - leftInset - rightInset, height: 48.0)
                    
                default:
                    break
                }
            }
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        // Width is ignored
        let ignoredWidth: CGFloat = 100
        
        if let section = Section(rawValue: section)
        {
            switch section {
            case .profileHeader:
                
                return CGSize(width: ignoredWidth, height: CGFloat(0.01))
                
            case .activity:
                
                return CGSize(width: ignoredWidth, height: CGFloat(32.0))
                
            case .other:
                
                return CGSize(width: ignoredWidth, height: CGFloat(32.0))
                
            default:
                break
            }
        }
        
        return CGSize(width: ignoredWidth, height: CGFloat(0.01))
    }
    
    // MARK: Product List Delegate
    func reloadData(_ row: UserActivity ,completion: LRCompletionBlock?) {
        
        if row == .purchases
        {
            LRSessionManager.sharedManager.loadProduct(NSNumber(value: 512141429 as Int32), completionHandler: { (success, error, response) -> Void in
                
                if let completion = completion
                {
                    completion(success, error, response)
                }
            })
        }
        else if row == .recentlyViewed
        {
            LRSessionManager.sharedManager.loadProduct(NSNumber(value: 533783711 as Int32), completionHandler: { (success, error, response) -> Void in
                
                if let completion = completion
                {
                    completion(success, error, response)
                }
            })
        }
        else if row == .saved
        {
            LRSessionManager.sharedManager.loadProduct(NSNumber(value: 487066353 as Int32), completionHandler: { (success, error, response) -> Void in
                
                if let completion = completion
                {
                    completion(success, error, response)
                }
            })
        }
        else if row == .myComments
        {
            LRSessionManager.sharedManager.loadProduct(NSNumber(value: 505709302 as Int32), completionHandler: { (success, error, response) -> Void in
                
                if let completion = completion
                {
                    completion(success, error, response)
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
