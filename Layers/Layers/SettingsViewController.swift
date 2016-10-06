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
    case account = 0, legal, signOut, _Count
}

private enum AccountRow: Int
{
    case pushNotifications = 0, emailPreferences, _Count
}

private enum LegalRow: Int
{
    case terms = 0, privacy, openSource, _Count
}

class SettingsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.register(UINib(nibName: "HeaderView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.register(UINib(nibName: "HeaderView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "HeaderView")
    }
    
    // MARK: Actions
    func logout()
    {
        // Should also clear credentials
        
        AppStateTransitioner.transitionToLoginStoryboard(true)
    }
    
    // MARK: Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return Section._Count.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let section = Section(rawValue: section)
        {
            switch section {
            case .account:
                
                return AccountRow._Count.rawValue
                
            case .legal:
                
                return LegalRow._Count.rawValue
                
            case .signOut:
                
                return 1
                
            default:
                break
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BasicCollectionCell", for: indexPath) as! BasicCollectionCell
        
        cell.backgroundColor = Color.white
        
        if let section = Section(rawValue: (indexPath as NSIndexPath).section)
        {
            let textAttributes = FontAttributes.defaultTextAttributes
            
            if section == .account
            {
                if let row = AccountRow(rawValue: (indexPath as NSIndexPath).row)
                {
                    if row == .pushNotifications
                    {
                        cell.titleLabel.attributedText = NSAttributedString(string: "Push Notifications", attributes: textAttributes)
                    }
                    else if row == .emailPreferences
                    {
                        cell.titleLabel.attributedText = NSAttributedString(string: "Email Preferences", attributes: textAttributes)
                    }
                }
            }
            else if section == .legal
            {
                if let row = LegalRow(rawValue: (indexPath as NSIndexPath).row)
                {
                    switch row {
                    case .terms:
                        
                        cell.titleLabel.attributedText = NSAttributedString(string: "Terms", attributes: textAttributes)
                        
                    case .privacy:
                        
                        cell.titleLabel.attributedText = NSAttributedString(string: "Privacy", attributes: textAttributes)
                        
                    case .openSource:
                        
                        cell.titleLabel.attributedText = NSAttributedString(string: "Open Source", attributes: textAttributes)
                        
                    default:
                        break
                    }
                }
            }
            else if section == .signOut
            {
                if (indexPath as NSIndexPath).row == 0
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
                    if section == .account
                    {
                        headerView.sectionTitleLabel.attributedText = NSAttributedString(string: "My Account".uppercased(), attributes: textAttributes)
                    }
                    else if section == .legal
                    {
                        headerView.sectionTitleLabel.attributedText = NSAttributedString(string: "Legal".uppercased(), attributes: textAttributes)
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
            if let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as? HeaderView
            {
                footerView.backgroundColor = Color.clear
                
                let textAttributes = [NSFontAttributeName: Font.PrimaryFontRegular(size: 12.0),
                                      NSForegroundColorAttributeName: Color.LightGray,
                                      NSKernAttributeName:0.7] as [String : Any]
                
                if let section = Section(rawValue: (indexPath as NSIndexPath).section)
                {
                    if section == .signOut
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let section = Section(rawValue: (indexPath as NSIndexPath).section)
        {
            switch section {
            case .account:
                
                // Do stuff with Account
                break
                
            case .legal:
                
                if let legalRow: LegalRow = LegalRow(rawValue: (indexPath as NSIndexPath).row)
                {
                    switch legalRow {
                    case .terms:
                        https://trylayers.com/terms/
                            //Show Terms
                            if let url = URL(string: "https://trylayers.com/terms/")
                        {
                            showWebBrowser(url)
                        }
                        
                    case .privacy:
                        
                        // Show Privacy
                        if let url = URL(string: "https://trylayers.com/privacy/")
                        {
                            showWebBrowser(url)
                        }
                        
                    case .openSource:
                        
                        //Show Open Source
                        let storyboard = UIStoryboard(name: "Account", bundle: Bundle.main)
                        
                        if let openSourceVc = storyboard.instantiateViewController(withIdentifier: "OpenSourceViewController") as? OpenSourceViewController
                        {
                            navigationController?.pushViewController(openSourceVc, animated: true)
                        }
                        
                    default:
                        break
                    }
                }
                
            case .signOut:
                
                if LRSessionManager.sharedManager.isAuthenticated()
                {
                    AppStateTransitioner.transitionToLoginStoryboard(true)
                }
                else
                {
                    if (indexPath as NSIndexPath).row == 0
                    {
                        if !LRSessionManager.sharedManager.isAuthenticated()
                        {
                            // Show login screen so user can pick sign up method
                            AppStateTransitioner.transitionToLoginStoryboard(true)
                        }
                        else
                        {
                            // Show alert to confirm logout
                            let alertController = UIAlertController(title: "Are you sure you want to sign out?", message: nil, preferredStyle: .alert)
                            
                            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                            
                            alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (action) -> Void in
                                
                                self.logout()
                            }))
                            
                            DispatchQueue.main.async(execute: { () -> Void in
                                
                                self.present(alertController, animated: true, completion: nil)
                            })
                        }
                    }
                }
                
            default:
                break
            }
        }
    }
    
    func showWebBrowser(_ url: URL)
    {
        let webView = ProductWebViewController(url: url)
        
        let navController = ProductWebNavigationController(rootViewController: webView)
        navController.setNavigationBarHidden(true, animated: false)
        navController.modalPresentationStyle = .overFullScreen
        
        present(navController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if let section = Section(rawValue: section)
        {
            // Width is ignored
            let ignoredWidth: CGFloat = 100
            
            if section == .account
            {
                return CGSize(width: ignoredWidth, height: 48.0)
            }
            else if section == .legal
            {
                return CGSize(width: ignoredWidth, height: 40.0)
            }
            else if section == .signOut
            {
                return CGSize(width: ignoredWidth, height: 24.0)
            }
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        let ignoredWidth: CGFloat = 100.0
        
        if let section = Section(rawValue: section)
        {
            if section == .signOut
            {
                return CGSize(width: ignoredWidth, height: 24.0)
            }
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItem(at: indexPath)
        {
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.HighlightedGrayColor
                
                }, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItem(at: indexPath)
        {
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.white
                
                }, completion: nil)
        }
    }
    
    // MARK: Collection View Delegate Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        {
            let viewWidth = view.bounds.size.width
            let leftInset = flowLayout.sectionInset.left
            let rightInset = flowLayout.sectionInset.right
            
            if let section = Section(rawValue: (indexPath as NSIndexPath).section)
            {
                switch section {
                case .account:
                    
                    return CGSize(width: viewWidth - leftInset - rightInset, height: 48.0)
                    
                case .legal:
                    
                    // Use code in .Other
                    return CGSize(width: viewWidth - leftInset - rightInset, height: 48.0)
                    
                case .signOut:
                    
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
