//
//  SettingsViewController.swift
//  Layers
//
//  Created by David Hodge on 9/11/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import FBSDKCoreKit

private enum Section: Int
{
    case Account = 0, Legal, SignOut, _Count
}

private enum AccountRow: Int
{
    case PushNotifications = 0, EmailPreferences, _Count
}

private enum LegalRow: Int
{
    case Terms = 0, Privacy, OpenSource, _Count
}

class SettingsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.registerNib(UINib(nibName: "HeaderView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.registerNib(UINib(nibName: "HeaderView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "HeaderView")
    }
    
    // MARK: Actions
    func logout()
    {
        // Should also clear credentials
        
        AppStateTransitioner.transitionToLoginStoryboard(true)
    }
    
    // MARK: Collection View Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return Section._Count.rawValue
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let section = Section(rawValue: section)
        {
            switch section {
            case .Account:
                
                return AccountRow._Count.rawValue
                
            case .Legal:
                
                return LegalRow._Count.rawValue
                
            case .SignOut:
                
                return 1
                
            default:
                break
            }
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BasicCollectionCell", forIndexPath: indexPath) as! BasicCollectionCell
        
        cell.backgroundColor = Color.whiteColor()
        
        if let section = Section(rawValue: indexPath.section)
        {
            let textAttributes = FontAttributes.defaultTextAttributes
            
            if section == .Account
            {
                if let row = AccountRow(rawValue: indexPath.row)
                {
                    if row == .PushNotifications
                    {
                        cell.titleLabel.attributedText = NSAttributedString(string: "Push Notifications", attributes: textAttributes)
                    }
                    else if row == .EmailPreferences
                    {
                        cell.titleLabel.attributedText = NSAttributedString(string: "Email Preferences", attributes: textAttributes)
                    }
                }
            }
            else if section == .Legal
            {
                if let row = LegalRow(rawValue: indexPath.row)
                {
                    switch row {
                    case .Terms:
                        
                        cell.titleLabel.attributedText = NSAttributedString(string: "Terms", attributes: textAttributes)
                        
                    case .Privacy:
                        
                        cell.titleLabel.attributedText = NSAttributedString(string: "Privacy", attributes: textAttributes)
                        
                    case .OpenSource:
                        
                        cell.titleLabel.attributedText = NSAttributedString(string: "Open Source", attributes: textAttributes)
                        
                    default:
                        break
                    }
                }
            }
            else if section == .SignOut
            {
                if indexPath.row == 0
                {
                    if LRSessionManager.sharedManager.isAuthenticated()
                    {
                        cell.titleLabel.attributedText = NSAttributedString(string: "Sign Out", attributes: textAttributes)
                    }
                    else
                    {
                        cell.titleLabel.attributedText = NSAttributedString(string: "Sign In", attributes: textAttributes)
                    }
                }
            }
        }
        
        return cell
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
                    if section == .Account
                    {
                        headerView.sectionTitleLabel.attributedText = NSAttributedString(string: "My Account".uppercaseString, attributes: textAttributes)
                    }
                    else if section == .Legal
                    {
                        headerView.sectionTitleLabel.attributedText = NSAttributedString(string: "Legal".uppercaseString, attributes: textAttributes)
                    }
                    else
                    {
                        headerView.sectionTitleLabel.attributedText = NSAttributedString(string: "", attributes: nil)
                    }
                }
                
                return headerView
            }
        }
        else if kind == UICollectionElementKindSectionFooter
        {
            if let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as? HeaderView
            {
                footerView.backgroundColor = Color.clearColor()
                
                let textAttributes = [NSFontAttributeName: Font.PrimaryFontRegular(size: 12.0),
                                      NSForegroundColorAttributeName: Color.LightGray,
                                      NSKernAttributeName:0.7]
                
                if let section = Section(rawValue: indexPath.section)
                {
                    if section == .SignOut
                    {
                        let versionNumber = "2.0.0"
                        
                        footerView.sectionTitleLabel.attributedText = NSAttributedString(string: "Version \(versionNumber)", attributes: textAttributes)
                    }
                }
                
                return footerView
            }
        }
        
        return UICollectionReusableView()
    }
    
    // MARK: Collection View Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if let section = Section(rawValue: indexPath.section)
        {
            switch section {
            case .Account:
                
                // Do stuff with Account
                break
                
            case .Legal:
                
                if let legalRow: LegalRow = LegalRow(rawValue: indexPath.row)
                {
                    switch legalRow {
                    case .Terms:
                        https://trylayers.com/terms/
                            //Show Terms
                            if let url = NSURL(string: "https://trylayers.com/terms/")
                        {
                            showWebBrowser(url)
                        }
                        
                    case .Privacy:
                        
                        // Show Privacy
                        if let url = NSURL(string: "https://trylayers.com/privacy/")
                        {
                            showWebBrowser(url)
                        }
                        
                    case .OpenSource:
                        
                        //Show Open Source
                        let storyboard = UIStoryboard(name: "Account", bundle: NSBundle.mainBundle())
                        
                        if let openSourceVc = storyboard.instantiateViewControllerWithIdentifier("OpenSourceViewController") as? OpenSourceViewController
                        {
                            navigationController?.pushViewController(openSourceVc, animated: true)
                        }
                        
                    default:
                        break
                    }
                }
                
            case .SignOut:
                
                if LRSessionManager.sharedManager.isAuthenticated()
                {
                    AppStateTransitioner.transitionToLoginStoryboard(true)
                }
                else
                {
                    if indexPath.row == 0
                    {
                        if !LRSessionManager.sharedManager.isAuthenticated()
                        {
                            // Show login screen so user can pick sign up method
                            AppStateTransitioner.transitionToLoginStoryboard(true)
                        }
                        else
                        {
                            // Show alert to confirm logout
                            let alertController = UIAlertController(title: "Are you sure you want to sign out?", message: nil, preferredStyle: .Alert)
                            
                            alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                            
                            alertController.addAction(UIAlertAction(title: "Sign Out", style: .Destructive, handler: { (action) -> Void in
                                
                                self.logout()
                            }))
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                            })
                        }
                    }
                }
                
            default:
                break
            }
        }
    }
    
    func showWebBrowser(url: NSURL)
    {
        let webView = ProductWebViewController(URL: url)
        
        let navController = ProductWebNavigationController(rootViewController: webView)
        navController.setNavigationBarHidden(true, animated: false)
        navController.modalPresentationStyle = .OverFullScreen
        
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if let section = Section(rawValue: section)
        {
            // Width is ignored
            let ignoredWidth: CGFloat = 100
            
            if section == .Account
            {
                return CGSize(width: ignoredWidth, height: 48.0)
            }
            else if section == .Legal
            {
                return CGSize(width: ignoredWidth, height: 40.0)
            }
            else if section == .SignOut
            {
                return CGSize(width: ignoredWidth, height: 24.0)
            }
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        let ignoredWidth: CGFloat = 100.0
        
        if let section = Section(rawValue: section)
        {
            if section == .SignOut
            {
                return CGSize(width: ignoredWidth, height: 24.0)
            }
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.HighlightedGrayColor
                
                }, completion: nil)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.whiteColor()
                
                }, completion: nil)
        }
    }
    
    // MARK: Collection View Delegate Flow Layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        {
            let viewWidth = view.bounds.size.width
            let leftInset = flowLayout.sectionInset.left
            let rightInset = flowLayout.sectionInset.right
            
            if let section = Section(rawValue: indexPath.section)
            {
                switch section {
                case .Account:
                    
                    return CGSize(width: viewWidth - leftInset - rightInset, height: 48.0)
                    
                case .Legal:
                    
                    // Use code in .Other
                    return CGSize(width: viewWidth - leftInset - rightInset, height: 48.0)
                    
                case .SignOut:
                    
                    return CGSize(width: viewWidth - leftInset - rightInset, height: 48.0)
                    
                default:
                    break
                }
            }
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
