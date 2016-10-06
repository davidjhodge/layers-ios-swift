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
    case productHeader = 0, description, _Count
}

class MoreDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "More Details".uppercased()
        
        tableView.tableFooterView = UIView()
        
        tableView.backgroundColor = Color.BackgroundGrayColor
        
        tableView.separatorColor = Color.clear
        
        view.backgroundColor = Color.BackgroundGrayColor
    }

    // MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let section = Section(rawValue: (indexPath as NSIndexPath).section)
        {
            if section == .productHeader
            {
                if let cell: SimpleProductHeaderCell = tableView.dequeueReusableCell(withIdentifier: "SimpleProductHeaderCell") as? SimpleProductHeaderCell
                {
                    if let product = product
                    {
                        if let primaryImageUrl = product.primaryImageUrl(ImageSizeKey.Normal)
                        {
                            cell.productImageView.sd_setImage(with: primaryImageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                                
                                if image != nil && cacheType != .memory
                                {
                                    cell.productImageView.alpha = 0.0
                                    
                                    UIView.animate(withDuration: 0.3, animations: {
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
                        
                        cell.ctaLabel.attributedText = NSAttributedString(string: "View Online".uppercased(), attributes: FontAttributes.buttonAttributes)
                    }
                    
                    return cell
                }
            }
            else if section == .description
            {
                if let cell: FreeformTextCell = tableView.dequeueReusableCell(withIdentifier: "FreeformTextCell") as? FreeformTextCell
                {
                    cell.headerLabel.text = "Description".uppercased()
                    
                    if let productDescription = product?.productDescription
                    {
                        cell.bodyTextLabel.attributedText = NSAttributedString(string: productDescription, attributes: FontAttributes.bodyTextAttributes)
                    }
                    
                    cell.selectionStyle = .none

                    return cell
                }
            }
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
    }
    
    
    // MARK: Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath as NSIndexPath).section == Section.productHeader.rawValue
        {
            if let product = product
            {
                if let productUrl = product.outboundUrl
                {
                    showWebBrowser(productUrl as URL)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == Section.description.rawValue
        {
            return 8.0
        }
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if let headerView: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView
        {
            headerView.backgroundColor = Color.BackgroundGrayColor
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: SFSafariViewController
    
    func showWebBrowser(_ url: URL)
    {
        let webView = ProductWebViewController(url: url)
        
        let navController = ProductWebNavigationController(rootViewController: webView)
        navController.setNavigationBarHidden(true, animated: false)
        navController.modalPresentationStyle = .overFullScreen
        
        present(navController, animated: true, completion: nil)
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
