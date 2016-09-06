//
//  MoreDetailsViewController.swift
//  Layers
//
//  Created by David Hodge on 9/5/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

private enum Section: Int
{
    case ProductHeader = 0, Description, _Count
}

class MoreDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "More Details".uppercaseString
        
        tableView.tableFooterView = UIView()
        
        tableView.backgroundColor = Color.BackgroundGrayColor
        
        tableView.separatorColor = Color.clearColor()
        
        view.backgroundColor = Color.BackgroundGrayColor
    }

    // MARK: Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let section = Section(rawValue: indexPath.section)
        {
            if section == .ProductHeader
            {
                if let cell: SimpleProductHeaderCell = tableView.dequeueReusableCellWithIdentifier("SimpleProductHeaderCell") as? SimpleProductHeaderCell
                {
                    if let product = product
                    {
                        if let primaryImageUrl = product.primaryImageUrl(ImageSizeKey.Normal)
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
                    

                        cell.productImageView.image = nil
                    
                        if let brand = product.brand?.name
                        {
                            cell.brandLabel.text = brand
                        }
                        
                        if let productName = product.unbrandedName
                        {
                            cell.productNameLabel.text = productName
                        }
                        
                        cell.ctaLabel.attributedText = NSAttributedString(string: "View Online".uppercaseString, attributes: FontAttributes.buttonAttributes)
                    }
                    
                    return cell
                }
            }
            else if section == .Description
            {
                if let cell: FreeformTextCell = tableView.dequeueReusableCellWithIdentifier("FreeformTextCell") as? FreeformTextCell
                {
                    cell.headerLabel.text = "Description".uppercaseString
                    
                    if let productDescription = product?.productDescription
                    {
                        cell.bodyTextLabel.attributedText = NSAttributedString(string: productDescription, attributes: FontAttributes.bodyTextAttributes)
                    }
                    
                    cell.selectionStyle = .None

                    return cell
                }
            }
        }
        
        return UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
    }
    
    
    // MARK: Table View Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == Section.ProductHeader.rawValue
        {
            if let product = product
            {
                if let productUrl = product.outboundUrl
                {
                    showWebBrowser(productUrl)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == Section.Description.rawValue
        {
            return 8.0
        }
        
        return 0.01
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 128
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if let headerView: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView
        {
            headerView.backgroundColor = Color.BackgroundGrayColor
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: SFSafariViewController
    
    func showWebBrowser(url: NSURL)
    {
        let webView = ProductWebViewController(URL: url)
        
        let navController = ProductWebNavigationController(rootViewController: webView)
        navController.setNavigationBarHidden(true, animated: false)
        navController.modalPresentationStyle = .OverFullScreen
        
        presentViewController(navController, animated: true, completion: nil)
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
