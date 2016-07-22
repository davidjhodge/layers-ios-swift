//
//  PriceAlertsViewController.swift
//  Layers
//
//  Created by David Hodge on 5/2/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import SDWebImage

private enum TableSection: Int
{
    case OnSale = 0, Watching, Count
}

class PriceAlertsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyStateView: UIView!
    
    @IBOutlet weak var startDiscoveringButton: UIButton!
    
    var saleAlerts: Array<ProductResponse>?
    
    var watchAlerts: Array<ProductResponse>?
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    var refreshControl = UIRefreshControl()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "price alerts".uppercaseString
        
        tabBarItem.title = "alerts".uppercaseString
        tabBarItem.image = UIImage(named: "bell")
        tabBarItem.image = UIImage(named: "bell-filled")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.BackgroundGrayColor
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Color.BackgroundGrayColor
        tableView.contentInset = UIEdgeInsets(top: 8.0, left: tableView.contentInset.left, bottom: tableView.contentInset.bottom, right: tableView.contentInset.right)
        
//        tableView.allowsMultipleSelectionDuringEditing = true
        
        spinner.color = Color.grayColor()
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = Color.lightGrayColor()
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.userInteractionEnabled = false
        
        startDiscoveringButton.setTitleColor(Color.whiteColor(), forState: [.Normal, .Highlighted])

        startDiscoveringButton.setBackgroundColor(Color.NeonBlueColor, forState: .Normal)
        startDiscoveringButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .Highlighted)
        
        startDiscoveringButton.addTarget(self, action: #selector(startDiscovering), forControlEvents: .TouchUpInside)
        
        startDiscoveringButton.adjustsImageWhenHighlighted = false
        
        // Reload table when new sale alert is created in another View Controller
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newSaleAlertCreated(_:)), name: kSaleAlertCreatedNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(saleAlertDeleted), name: kSaleAlertDeletedNotification, object: nil)
        
        reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        spinner.center = tableView.center
    }
    
    // MARK: Networking

    func reloadData()
    {
        // Show center spinner on first load
        if saleAlerts == nil && watchAlerts == nil
        {
            refreshControl.hidden = true

            spinner.hidden = false
            spinner.startAnimating()
        }
        
        if emptyStateView.hidden == false
        {
            tableView.hidden = false
            
            emptyStateView.hidden = true
        }

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        LRSessionManager.sharedManager.loadSaleAlerts({ (success, error, response) -> Void in
         
            // Stop loading indicators
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.spinner.stopAnimating()
                
                if self.tableView.userInteractionEnabled == false
                {
                    self.tableView.userInteractionEnabled = true
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
            
            if success
            {
                if let alerts = response as? SaleAlertResponse
                {
                    if let saleAlerts = alerts.saleProducts
                    {
                        self.saleAlerts = saleAlerts
                    }
                    
                    if let watchingAlerts = alerts.watchingProducts
                    {
                        self.watchAlerts = watchingAlerts
                    }
                    
                    if self.refreshControl.refreshing
                    {
                        // Log Refresh
                        FBSDKAppEvents.logEvent("Discover Refresh Events")
                        
                        CATransaction.begin()
                        CATransaction.setCompletionBlock({ () -> Void in
                            
                            self.hardReloadTableView()
                        })
                        
                        self.refreshControl.endRefreshing()
                        CATransaction.commit()
                    }
                    else
                    {
                        // By default, refresh table view immediately
                        self.hardReloadTableView()
                    }
                }
                
                if let saleAlerts = self.saleAlerts,
                    let watchAlerts = self.watchAlerts
                {
                    if saleAlerts.count == 0 && watchAlerts.count == 0
                    {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.tableView.hidden = true

                            self.emptyStateView.hidden = false
                        })
                    }
                }
                
                // Show/hide Edit button as needed
                if self.navigationItem.leftBarButtonItem == nil
                    && (self.saleAlerts?.count > 0 || self.watchAlerts?.count > 0)
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.navigationItem.leftBarButtonItem = self.editButtonItem()
                        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:Font.OxygenRegular(size: 16.0)], forState: .Normal)
                    })
                }
                else if self.navigationItem.leftBarButtonItem != nil
                && (self.saleAlerts?.count == 0 && self.watchAlerts?.count == 0)
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.navigationItem.leftBarButtonItem = nil
                    })
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if self.refreshControl.refreshing
                    {
                        self.refreshControl.endRefreshing()
                    }
        
                    let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if self.refreshControl.refreshing
                {
                    self.refreshControl.endRefreshing()
                }
            })
        })
    }
    
    func hardReloadTableView()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.tableView.reloadData()
        })
    }
    
    func deleteAlertAtIndexPath(indexPath: NSIndexPath)
    {
        if indexPath.section == TableSection.OnSale.rawValue
        {
            // Remove item from data model
            deleteAlert(indexPath, alertSection: TableSection.OnSale)
            
            return
        }
        else if indexPath.section == TableSection.Watching.rawValue
        {
            // Remove item from data model
            deleteAlert(indexPath, alertSection: TableSection.Watching)
            
            return
        }
        
        // If any step above fails, this error statement will be logged
        log.debug("Failed to Delete Price Alert.")
    }
    
    private func deleteAlert(indexPath: NSIndexPath, alertSection tableSection: TableSection)
    {
        var index = indexPath.row
        
        // Handle seperators
        if indexPath.row > 0
        {
            index = (indexPath.row / 2)
        }
        
        // Define index paths
        var indexPaths = [indexPath]
        
        // Delete item
        var alertsCopy: Array<ProductResponse>?
        
        if tableSection == TableSection.OnSale
        {
            let saleAlertsCopy = saleAlerts
            
            alertsCopy = saleAlertsCopy
            
            saleAlerts?.removeAtIndex(index)
        }
        else if tableSection == TableSection.Watching
        {
            let watchAlertsCopy = watchAlerts
            
            alertsCopy = watchAlertsCopy
            
            watchAlerts?.removeAtIndex(index)
        }
        
        // Remove bottom seperator too unless last product
        if alertsCopy?.count != 1
        {
            if index == 0
            {
                indexPaths.append(NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section))
            }
            else
            {
                indexPaths.append(NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section))
            }
        }
        else
        {
            indexPaths.append(NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section))
        }

        // Remove row from UI
        
        if alertsCopy?.count == 1
        {
            // If 1 alert, reload enire table. If no alerts are left, show empty state
            tableView.reloadData()
            
            if let saleAlerts = self.saleAlerts,
                let watchAlerts = self.watchAlerts
            {
                if saleAlerts.count == 0 && watchAlerts.count == 0
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.tableView.hidden = true
                        
                        self.emptyStateView.hidden = false
                    })
                }
            }
        }
        else
        {
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            tableView.endUpdates()
        }
        
        if tableView.contentSize.height > tableView.bounds.size.height
        {
            let cellHeight = CGFloat(112.0 + 8.0)
            
            tableView.contentSize = CGSizeMake(tableView.contentSize.width, tableView.contentSize.height - cellHeight)
        }
        
        if let alertProduct: ProductResponse = alertsCopy?[safe: index]
        {
            if let productId = alertProduct.productId
            {
                LRSessionManager.sharedManager.deleteSaleAlert(productId, completionHandler: { (success, error, response) -> Void in
                    
                    if success
                    {
                        log.debug("Sale alert deleted.")
                    }
                    else
                    {
                        if let errorMessage = error
                        {
                            log.error(errorMessage)
                        }
                        
                        // Reset UI to state before deletion
                        if tableSection == TableSection.OnSale
                        {
                            self.saleAlerts = alertsCopy
                        }
                        else if tableSection == TableSection.Watching
                        {
                            self.watchAlerts = alertsCopy
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.tableView.reloadData()

                            let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                    }
                })
            }
        }
    }
    
    // MARK: Actions
    func refresh()
    {
        refreshControl.beginRefreshing()
        
        reloadData()
    }
    
    func newSaleAlertCreated(notification: NSNotification)
    {
        reloadData()
    }
    
    func saleAlertDeleted(notification: NSNotification)
    {
        reloadData()
    }
    
    func startDiscovering()
    {
        if let tabBarVc = tabBarController
        {
            if let navController = tabBarVc.viewControllers?[safe: 0] as? UINavigationController
            {
                navController.popToRootViewControllerAnimated(false)
            }
            
            tabBarVc.selectedIndex = 0
        }
    }
    
    // MARK: UITableView Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == TableSection.OnSale.rawValue
        {
            if let alerts = saleAlerts
            {
                if alerts.count == 0
                {
                    return 0
                }
                else
                {
                    //Account for seperators
                    return alerts.count * 2 - 1
                }
            }
        }
        else if section == TableSection.Watching.rawValue
        {
            if let alerts = watchAlerts
            {
                if alerts.count == 0
                {
                    return 0
                }
                else
                {
                    return alerts.count * 2 - 1
                }
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == false
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("PriceAlertCell") as! PriceAlertCell
            
            cell.accessoryType = .DisclosureIndicator
            cell.selectionStyle = .None
            
            cell.brandLabel.text = ""
            cell.productLabel.text = ""
            cell.priceLabel.text = ""
            cell.productImageView.image = nil
            
            var index = indexPath.row
            
            // Handle seperators
            if indexPath.row > 0
            {
                index = (indexPath.row / 2)
            }
            
            let numberFormatter: NSNumberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .CurrencyStyle
            
            if indexPath.section == TableSection.OnSale.rawValue
            {
                if let alerts = saleAlerts
                {
                    if let product = alerts[safe: index] as ProductResponse?
                    {
                        if let brandName = product.brand?.brandName
                        {
                            cell.brandLabel.text = brandName.uppercaseString
                        }
                        
                        if let productName = product.productName
                        {
                            cell.productLabel.text = productName
                        }
                        
                        if let firstVariant = product.variants?[safe: 0]
                        {
                            if let firstSize = firstVariant.sizes?[safe: 0]
                            {
                                if let priceObject = firstSize.price
                                {
                                    if let retailPrice = priceObject.retailPrice
                                    {
                                        let retailString = NSAttributedString.priceStringWithRetailPrice(retailPrice, size: 10.0, strikethrough: true)
                                        
                                        if let salePrice = priceObject.price where retailPrice != priceObject.price
                                        {
                                            if salePrice != retailPrice
                                            {
                                                let saleString = NSAttributedString.priceStringWithSalePrice(salePrice, size: 14.0)
                                                
                                                let finalString = NSMutableAttributedString(attributedString: retailString)
                                                
                                                finalString.appendAttributedString(NSAttributedString(string: " "))
                                                
                                                finalString.appendAttributedString(saleString)
                                                
                                                cell.priceLabel.attributedText = NSAttributedString(attributedString: finalString)
                                            }
                                        }
                                        else
                                        {
                                            let retailString = NSAttributedString.priceStringWithRetailPrice(retailPrice, size: 14.0, strikethrough: false)
                                            
                                            cell.priceLabel.attributedText = retailString
                                        }
                                    }
                                }
                            }
                            
                            if let primaryImageUrl = firstVariant.images?[safe: 0]?.primaryUrl
                            {
                                let resizedPrimaryUrl = NSURL.imageAtUrl(primaryImageUrl, imageSize: ImageSize.kImageSize116)

                                cell.productImageView.sd_setImageWithURL(resizedPrimaryUrl, placeholderImage: nil, options: SDWebImageOptions.ProgressiveDownload, completed: { (image, error, cacheType, imageUrl) -> Void in

//                                cell.productImageView.sd_setImageWithURL(primaryImageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                                
//                                    if image != nil && cacheType != .Memory
//                                    {
//                                        cell.productImageView.alpha = 0.0
//                                        
//                                        UIView.animateWithDuration(0.3, animations: {
//                                            cell.productImageView.alpha = 1.0
//                                        })
//                                    }
                                })
                            }
                        }
                        
                        return cell
                    }
                }
            }
            else if indexPath.section == TableSection.Watching.rawValue
            {
                if let alerts = watchAlerts
                {
                    if let product = alerts[safe: index] as ProductResponse?
                    {
                        if let brandName = product.brand?.brandName
                        {
                            cell.brandLabel.text = brandName.uppercaseString
                        }
                        
                        if let productName = product.productName
                        {
                            cell.productLabel.text = productName
                        }
                        
                        // Should be a "lowest price" field
                        if let firstVariant = product.variants?[safe: 0]
                        {
                            // First Size
                            if let firstSize = firstVariant.sizes?[safe: 0]
                            {
                                if let priceObject = firstSize.price
                                {
                                    if let retailPrice = priceObject.retailPrice
                                    {
                                        if let salePrice = priceObject.price where retailPrice != priceObject.price
                                        {
                                            let retailString = NSAttributedString.priceStringWithRetailPrice(retailPrice, size: 10.0, strikethrough: true)
                                            
                                            let finalString = NSMutableAttributedString(attributedString: retailString)

                                                let saleString = NSAttributedString.priceStringWithSalePrice(salePrice, size: 14.0)
                                                
                                                finalString.appendAttributedString(NSAttributedString(string: " "))

                                                finalString.appendAttributedString(saleString)
                                            
                                            cell.priceLabel.attributedText = NSAttributedString(attributedString: finalString)
                                        }
                                        else
                                        {
                                            let retailString = NSAttributedString.priceStringWithRetailPrice(retailPrice, size: 14.0, strikethrough: false)

                                            cell.priceLabel.attributedText = retailString
                                        }
                                    }
                                }
                            }
                            
                            // Primary Image
                            if let primaryImageUrl = firstVariant.images?[safe: 0]?.primaryUrl
                            {
                                let resizedPrimaryUrl = NSURL.imageAtUrl(primaryImageUrl, imageSize: ImageSize.kImageSize116)

                                cell.productImageView.sd_setImageWithURL(resizedPrimaryUrl, placeholderImage: nil, options: SDWebImageOptions.ProgressiveDownload, completed: { (image, error, cacheType, imageUrl) -> Void in

//                                cell.productImageView.sd_setImageWithURL(primaryImageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                                
//                                    if image != nil && cacheType != .Memory
//                                    {
//                                        cell.productImageView.alpha = 0.0
//                                        
//                                        UIView.animateWithDuration(0.3, animations: {
//                                            cell.productImageView.alpha = 1.0
//                                        })
//                                    }
                                })
                            }

                        }
                        
                        return cell
                    }
                }
            }
        }
        else
        {
            return tableView.dequeueReusableCellWithIdentifier("SeparatorCell")!
        }
        
        return UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == TableSection.OnSale.rawValue
        {
            if let _ = saleAlerts where saleAlerts?.count > 0
            {
                return "On Sale Now".uppercaseString
            }
            else
            {
                return ""
            }
        }
        else if section == TableSection.Watching.rawValue
        {
            if let _ = watchAlerts where watchAlerts?.count > 0
            {
                return "Watching".uppercaseString
            }
            else
            {
                return ""
            }
        }
        
        return ""
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = Color.clearColor()
        header.textLabel?.font = Font.OxygenBold(size: 14.0)
        header.textLabel?.textColor = Color.DarkNavyColor
    }
    
    // MARK: UITableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let navigationVc = navigationController
        {
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            
            if let productVc = storyboard.instantiateViewControllerWithIdentifier("ProductViewController") as? ProductViewController
            {
                var index = indexPath.row
                
                if indexPath.row > 0
                {
                    index = (indexPath.row / 2)
                }
                
                var product: ProductResponse?
                
                if indexPath.section == TableSection.OnSale.rawValue
                {
                    product = saleAlerts?[index]
                    
                    if let productName = product?.productName,
                        let productId = product?.productId
                    {
                        FBSDKAppEvents.logEvent("Sale Alert On Sale Product Views", parameters: ["Product Name":productName, "Product ID":productId])
                    }
                }
                else if indexPath.section == TableSection.Watching.rawValue
                {
                    product = watchAlerts?[index]
                    
                    if let productName = product?.productName,
                        let productId = product?.productId
                    {
                        FBSDKAppEvents.logEvent("Watch Alert On Sale Product Views", parameters: ["Product Name":productName, "Product ID":productId])
                    }
                }
                
                if let productId = product?.productId
                {
                    productVc.productIdentifier = productId
                }
                
                navigationVc.pushViewController(productVc, animated: true)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if indexPath.row % 2 == false
        {
            // Normal Cell
            return UITableViewAutomaticDimension
        }
        else
        {
            // Seperator Cell
            return 8.0
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 112.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == TableSection.OnSale.rawValue
        {
            if let _ = saleAlerts where saleAlerts?.count > 0
            {
                return 38.0
            }
        }
        else if section == TableSection.Watching.rawValue
        {
            if let _ = watchAlerts where watchAlerts?.count > 0
            {
                return 38.0
            }
        }
 
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        if section == TableSection.OnSale.rawValue
        {
            if let _ = saleAlerts where saleAlerts?.count > 0
            {
                return 8.0
            }
        }
        else if section == TableSection.Watching.rawValue
        {
            if let _ = watchAlerts where watchAlerts?.count > 0
            {
                return 8.0
            }
        }
        
        return 8.0
//        return 0.01
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.HighlightedGrayColor
                
                if let productCell = cell as? PriceAlertCell
                {
                    productCell.productImageView.alpha = 0.5
                }
                
                }, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.whiteColor()
                
                if let productCell = cell as? PriceAlertCell
                {
                    productCell.productImageView.alpha = 1.0
                }
                
                }, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete
        {
            deleteAlertAtIndexPath(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if indexPath.row % 2 == 0
        { 
            return true
        }
        
        return false
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return .Delete
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}