//
//  NotificationsViewController.swift
//  Layers
//
//  Created by David Hodge on 9/3/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import SDWebImage
import DateTools
import FRHyperLabel

//Temp
import ObjectMapper

class NotificationsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var notifications: Array<NotificationResponse>?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "notifications".uppercaseString
        
        tabBarItem.title = "Notifications"
        tabBarItem.image = UIImage(named: "notifications-bell")
        tabBarItem.selectedImage = UIImage(named: "notifications-bell-filled")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change status bar style to .LightContent
        navigationController?.navigationBar.barStyle = .Black
        
        view.backgroundColor = Color.BackgroundGrayColor
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        
        // TEMP
        let notificationDict = ["user_image_url": NSURL(string: "https://organicthemes.com/demo/profile/files/2012/12/profile_img.png")!,
        "user_name": "David Hodge",
        "timestamp": NSDate(timeIntervalSince1970: 1472951231),
        "product_image_url": NSURL(string: "https://organicthemes.com/demo/profile/files/2012/12/profile_img.png")!]
        
        if let notification = Mapper<NotificationResponse>().map(notificationDict)
        {
            notifications = [notification]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Collection View Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let notifications = notifications
        {
            return notifications.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell: NotificationCell = collectionView.dequeueReusableCellWithReuseIdentifier("NotificationCell", forIndexPath: indexPath) as? NotificationCell
        {
            cell.backgroundColor = Color.whiteColor()
            
            if let notification = notifications?[safe: indexPath.row]
            {
                // Left Image
                if let userImageUrl = notification.userImageUrl
                {
                    //                    let resizedImageUrl = NSURL.imageAtUrl(userImageUrl, imageSize: ImageSize.kImageSize116)
                    
                    cell.leftImageView.sd_setImageWithURL(userImageUrl, placeholderImage: nil, options: SDWebImageOptions.HighPriority, completed: { (image, error, cacheType, imageUrl) -> Void in
                        
                        if error != nil
                        {
                            if let placeholderImage = UIImage(named: "profile-image-placeholder")
                            {
                                cell.leftImageView.image = placeholderImage
                            }
                        }
                    })
                }
                
                // Content
                if let userName: String = notification.userName,
                let timestamp = notification.timestamp?.shortTimeAgoSinceNow()
                {
                    let attributedString = NSMutableAttributedString()
                    
                    attributedString.appendAttributedString(NSAttributedString(string: userName, attributes: [
                        NSFontAttributeName: Font.PrimaryFontRegular(size: 14.0),
                        NSForegroundColorAttributeName: Color.PrimaryAppColor
                        ]))
                    
                    attributedString.appendAttributedString(NSAttributedString(string: " just liked your purchase. ", attributes: [
                        NSFontAttributeName: Font.PrimaryFontLight(size: 14.0),
                        NSForegroundColorAttributeName: Color.DarkTextColor
                        ]))
                    
                    attributedString.appendAttributedString(NSAttributedString(string: timestamp, attributes: [
                        NSFontAttributeName: Font.PrimaryFontLight(size: 14.0),
                        NSForegroundColorAttributeName: Color.GrayColor
                        ]))
                    
                    cell.contentLabel.attributedText = attributedString
                    
                    // Link
                    cell.contentLabel.linkAttributeDefault = [
                                                              NSFontAttributeName: Font.PrimaryFontRegular(size: 14.0),
                                                              NSForegroundColorAttributeName: Color.PrimaryAppColor]
                    
                    cell.contentLabel.linkAttributeHighlight = [NSFontAttributeName: Font.PrimaryFontRegular(size: 14.0),
                                                                NSForegroundColorAttributeName: Color.HighlightedPrimaryAppColor]
                    
                    cell.contentLabel.setLinkForSubstring(userName, withLinkHandler: { (hyperLabel: FRHyperLabel!, substring: String!) -> Void in
                        
                        let storyboard = UIStoryboard(name: "Account", bundle: NSBundle.mainBundle())
                        
                        if let profileVc = storyboard.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController
                        {
                            self.navigationController?.pushViewController(profileVc, animated: true)
                        }
                    })
                }
                
                // Right Image
                if let productImageUrl = notification.productImageUrl
                {
//                    let resizedImageUrl = NSURL.imageAtUrl(productImageUrl, imageSize: ImageSize.kImageSize116)
                    
                    cell.rightImageView.sd_setImageWithURL(productImageUrl, placeholderImage: nil, options: SDWebImageOptions.HighPriority, completed: { (image, error, cacheType, imageUrl) -> Void in
                        
                        if error != nil
                        {
                            if let placeholderImage = UIImage(named: "profile-image-placeholder")
                            {
                                cell.leftImageView.image = placeholderImage
                            }
                        }
                    })
                    
                }
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    // MARK: Collection View Delegate
    
    // MARK: Collection View Delegate Flow Layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // Size for Product Cell
        let flowLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let width: CGFloat = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right)
        
        return CGSizeMake(width, 72.0)
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
