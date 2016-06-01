//
//  PriceAlertsViewController.swift
//  Layers
//
//  Created by David Hodge on 5/2/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

private enum TableSection: Int
{
    case OnSale = 0, Watching, Count
}

class PriceAlertsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var saleAlerts: Array<ProductResponse>?
    
    var watchAlerts: Array<ProductResponse>?
    
    var spinny = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "price alerts".uppercaseString
        
        tabBarItem.title = "alerts".uppercaseString
        tabBarItem.image = UIImage(named: "bell")
        tabBarItem.image = UIImage(named: "bell-filled")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Color.BackgroundGrayColor
        
        spinny.tintColor = Color.grayColor()
        spinny.hidesWhenStopped = true
        
        reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        spinny.center = view.center
    }
    
    // MARK: Networking
    //Reload Data
    func reloadData()
    {
        spinny.startAnimating()
        
        // SHOULD LOAD ONLY PRICE ALERT ITEMS FOR USER
        LRSessionManager.sharedManager.loadProductCollection(1, completionHandler: { (success, error, response) -> Void in
            
            self.spinny.stopAnimating()

            if success
            {
                if let productsResponse = response as? Array<ProductResponse>
                {
                    self.saleAlerts = [productsResponse[0]]
                    self.watchAlerts = [productsResponse[1]]

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.tableView.reloadData()
                    })
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        })
    }
    
    // MARK: UITableView Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        var sections = 0
        
        if saleAlerts != nil
        {
            sections += 1
        }
        
        if watchAlerts != nil
        {
            sections += 1
        }
        
        return sections
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == TableSection.OnSale.rawValue
        {
            if let alerts = saleAlerts
            {
                //Account for seperators
                return alerts.count * 2 - 1
            }
        }
        else if section == TableSection.Watching.rawValue
        {
            if let alerts = watchAlerts
            {
                return alerts.count * 2 - 1
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
            
            let numberFormatter: NSNumberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .CurrencyStyle
            
            if indexPath.section == TableSection.OnSale.rawValue
            {
                if let alerts = saleAlerts
                {
                    if let product = alerts[safe: 0] as ProductResponse?
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
                                if let priceObject = firstSize.prices?[safe: 0]
                                {
                                    if let price = priceObject.price
                                    {
                                        cell.priceLabel.attributedText = NSAttributedString(string: numberFormatter.stringFromNumber(price)!, attributes: [NSForegroundColorAttributeName: Color.RedColor, NSFontAttributeName: Font.OxygenBold(size: 14.0)])
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
                    if let product = alerts[0] as ProductResponse?
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
                                if let priceObject = firstSize.prices?[safe: 0]
                                {
                                    if let price = priceObject.price
                                    {
                                        cell.priceLabel.attributedText = NSAttributedString(string: numberFormatter.stringFromNumber(price)!, attributes: [NSForegroundColorAttributeName: Color.DarkNavyColor, NSFontAttributeName: Font.OxygenBold(size: 14.0)])
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
            return "On Sale Now".uppercaseString
        }
        else if section == TableSection.Watching.rawValue
        {
            return "Watching".uppercaseString
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
            return 112.0
        }
        else
        {
            // Seperator Cell
            return 8.0
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8.0
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

                            if let url = alertProduct.outboundUrl
                            {
                                destinationVC.webURL = NSURL(string: url)
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
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}