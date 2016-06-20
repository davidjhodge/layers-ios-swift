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
        
//        navigationItem.leftBarButtonItem = editButtonItem()
        
        spinner.color = Color.grayColor()
        spinner.hidesWhenStopped = true
//        view.bringSubviewToFront(spinner)
        view.addSubview(spinner)
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = Color.lightGrayColor()
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        refreshControl.hidden = true
        
        startDiscoveringButton.addTarget(self, action: #selector(startDiscovering), forControlEvents: .TouchUpInside)
        
        // Reload table when new sale alert is created in another View Controller
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newSaleAlertCreated(_:)), name: kSaleAlertCreatedNotification, object: nil)
        
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
                
                if self.refreshControl.hidden == true
                {
                    self.refreshControl.hidden = false
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                // If refresh control is animating, stop the animation
                if self.refreshControl.refreshing
                {
                    self.refreshControl.endRefreshing()
                }
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
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.refreshControl.endRefreshing()
                        })
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
        var index = indexPath.row
        
        // Handle seperators
        if indexPath.row > 0
        {
            index = (indexPath.row / 2)
        }
    
        if indexPath.section == TableSection.OnSale.rawValue
        {
            if var saleAlerts = saleAlerts
            {
                if let alertProduct: ProductResponse = saleAlerts[safe: index]
                {
                    // Remove row from UI
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    
                    deleteAlert(index, product: alertProduct, inAlerts: &saleAlerts)
                    
                    return
                }
            }
        }
        else if indexPath.section == TableSection.Watching.rawValue
        {
            if var watchAlerts = watchAlerts
            {
                if let alertProduct: ProductResponse = watchAlerts[safe: index]
                {
                    // Remove row from UI
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

                    deleteAlert(index, product: alertProduct, inAlerts: &watchAlerts)
                    
                    return
                }
            }
        }
        
        // If any step above fails, this error statement will be logged
        log.debug("Failed to Delete Price Alert.")
    }
    
    func deleteAlert(index: Int, product: ProductResponse, inout inAlerts alerts: Array<ProductResponse>)
    {
        let alertsCopy = alerts
        
        alerts.removeAtIndex(index)
        
        if let productId = product.productId
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
                    alerts = alertsCopy
                    
                    self.tableView.reloadData()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            })
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
//        var sections = 0
//        
//        if let saleAlerts = saleAlerts
//        {
//            if saleAlerts.count > 0
//            {
//                sections += 1
//            }
//        }
//        
//        if let watchAlerts = watchAlerts
//        {
//            if watchAlerts.count > 0
//            {
//                sections += 1
//            }
//        }
//        
//        return sections
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
                        
                        // Should be a "lowest price" field
                        if let firstVariant = product.variants?[safe: 0]
                        {
                            if let firstSize = firstVariant.sizes?[safe: 0]
                            {
                                if let priceObject = firstSize.price
                                {
                                    if let salePrice = priceObject.price, retailPrice = priceObject.retailPrice
                                    {
                                        let retailString = NSAttributedString.priceStringWithRetailPrice(retailPrice, size: 10.0, strikethrough: true)
                                        
                                        let saleString = NSAttributedString(string: " \(salePrice.stringValue)", attributes: [NSForegroundColorAttributeName: Color.RedColor, NSFontAttributeName: Font.OxygenBold(size: 14.0)])
                                        
                                        let finalString = NSMutableAttributedString(attributedString: retailString)
                                        
                                        finalString.appendAttributedString(saleString)
                                        
                                        cell.priceLabel.attributedText = NSAttributedString(attributedString: finalString)
                                    }
                                }
                            }
                            
                            if let primaryImageUrl = firstVariant.images?[safe: 0]?.primaryUrl
                            {
                                cell.productImageView.sd_setImageWithURL(primaryImageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                                    
                                    if image != nil && cacheType != .Memory
                                    {
                                        cell.productImageView.alpha = 0.0
                                        
                                        UIView.animateWithDuration(0.3, animations: {
                                            cell.productImageView.alpha = 1.0
                                        })
                                    }
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
                                    if let price = priceObject.price
                                    {
                                        cell.priceLabel.attributedText = NSAttributedString(string: price.stringValue, attributes: [NSForegroundColorAttributeName: Color.DarkTextColor, NSFontAttributeName: Font.OxygenBold(size: 14.0)])
                                    }
                                }
                            }
                            
                            // Primary Image
                            if let primaryImageUrl = firstVariant.images?[safe: 0]?.primaryUrl
                            {
                                cell.productImageView.sd_setImageWithURL(primaryImageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                                    
                                    if image != nil && cacheType != .Memory
                                    {
                                        cell.productImageView.alpha = 0.0
                                        
                                        UIView.animateWithDuration(0.3, animations: {
                                            cell.productImageView.alpha = 1.0
                                        })
                                    }
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
        
        performSegueWithIdentifier("ShowProductWebViewController", sender: indexPath)
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
        
        if indexPath.row % 2 == false
        {
            return true
        }
        
        return false
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return .Delete
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowProductWebViewController"
        {
            if let destinationVC = segue.destinationViewController as? ProductWebViewController
            {
                if let indexPath = sender as? NSIndexPath
                {
                    // Integrates with dummy seperator cells
                    var row = 0
                    
                    if indexPath.row == 0
                    {
                        row = 0
                    }
                    else if indexPath.row > 0
                    {
                        row = Int(floor(Double(indexPath.row)  * 0.5))
                    }
                    
                    if indexPath.section == TableSection.OnSale.rawValue
                    {
                        if let alertProduct = saleAlerts?[safe: row] as ProductResponse?
                        {
                            if let brandName = alertProduct.brand?.brandName
                            {
                                destinationVC.brandName = brandName
                            }
                            
                            if let coupon = alertProduct.variants?[safe: 0]?.sizes?[safe: 0]?.altPrice?.couponCode
                            {
                                destinationVC.couponCode = coupon
                            }

                            if let url = alertProduct.outboundUrl
                            {
                                destinationVC.webURL = NSURL(string: url)
                            }
                            
                            if let productName = alertProduct.productName,
                            let productId = alertProduct.productId
                            {
                                FBSDKAppEvents.logEvent("Sale Alert On Sale Product Views", parameters: ["Product Name":productName, "Product ID":productId])
                            }
                        }
                    }
                    else if indexPath.section == TableSection.Watching.rawValue
                    {
                        if let alertProduct = watchAlerts?[safe: row] as ProductResponse?
                        {
                            if let brandName = alertProduct.brand?.brandName
                            {
                                destinationVC.brandName = brandName
                            }
                            
                            if let url = alertProduct.outboundUrl
                            {
                                destinationVC.webURL = NSURL(string: url)
                            }
                            
                            if let productName = alertProduct.productName,
                                let productId = alertProduct.productId
                            {
                                FBSDKAppEvents.logEvent("Sale Alert Watching Product Views", parameters: ["Product Name":productName, "Product ID":productId])
                            }
                        }
                    }
                }
            }
        }
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}