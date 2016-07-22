//
//  ReviewsViewController.swift
//  Layers
//
//  Created by David Hodge on 4/12/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

private enum TableSection: Int
{
    case ProductHeader = 0, OverallReviews, Reviews, Count
}

class ReviewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var productId: NSNumber?
    
    var product: ProductResponse?
    
    var reviews: Array<ReviewResponse>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Reviews".uppercaseString
        
        tableView.estimatedRowHeight = 128.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        reloadData()
    }
    
    // MARK: Networking
    func reloadData()
    {
        if let productIdentifier = productId
        {
            LRSessionManager.sharedManager.loadReviewsForProduct(productIdentifier, completionHandler: { (success, error , response) -> Void in
             
                if success
                {
                    if let reviews = response as? Array<ReviewResponse>
                    {
                        self.reviews = reviews
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            
                            self.tableView.reloadData()
                        })
                    }
                }
                else
                {
                    let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
        else
        {
            let alert = UIAlertController(title: "NO_PRODUCT_ID".localized, message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Actions
    func ctaSelected()
    {
        performSegueWithIdentifier("ShowProductWebViewController", sender: self)
    }
    
    // MARK: Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return TableSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection {
            case .ProductHeader:
                return 1
                
            case .OverallReviews:
                return 1
                
            case .Reviews:
                
                if let reviews = reviews
                {
                    return reviews.count
                }
                
            default:
                return 0
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let tableSection: TableSection = TableSection(rawValue: indexPath.section)
        {
            switch tableSection {
            case .ProductHeader:
                
                let cell: SimpleProductHeaderCell = tableView.dequeueReusableCellWithIdentifier("SimpleProductHeaderCell") as! SimpleProductHeaderCell
                
                if let product = product
                {
                    cell.selectionStyle = .None
                    
                    cell.productImageView.image = UIImage()
                    cell.brandLabel.text = ""
                    cell.productNameLabel.text = ""
                    
                    if let imageUrl = product.variants?[safe: 0]?.images?[safe: 0]?.primaryUrl
                    {
                        let resizedPrimaryUrl = NSURL.imageAtUrl(imageUrl, imageSize: ImageSize.kImageSize116)

                        cell.productImageView.sd_setImageWithURL(resizedPrimaryUrl, completed: { (image, error, cacheType, url) -> Void in
                            
//                            if image != nil && cacheType != .Memory
//                            {
//                                cell.productImageView.alpha = 0.0
//                                
//                                UIView.animateWithDuration(0.3, animations: {
//                                    cell.productImageView.alpha = 1.0
//                                })
//                            }
                        })
                    }
                    
                    if let brandName = product.brand?.brandName
                    {
                        cell.brandLabel.text = brandName
                    }
                    
                    if let productName = product.productName
                    {
                        cell.productNameLabel.text = productName
                    }
                    
                    cell.ctaButton.setBackgroundColor(Color.NeonBlueColor, forState: .Normal)
                    cell.ctaButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .Highlighted)
                    
                    cell.ctaButton.addTarget(self, action: #selector(ctaSelected), forControlEvents: .TouchUpInside)
                }

                return cell
                
            case .OverallReviews:
                
                if indexPath.row == 0
                {
                    let cell: OverallReviewCell = tableView.dequeueReusableCellWithIdentifier("OverallReviewCell") as! OverallReviewCell
                    
                    cell.ratingLabel.text = ""
                    cell.starView.rating = 0.0
                    cell.rightLabel.text = ""
                    
                    if let rating = product?.rating?.score, totalRating = product?.rating?.total, reviews = reviews
                    {
                        cell.ratingLabel.text = "\(rating.stringValue) / \(totalRating)"
                        
                        cell.starView.rating = rating.doubleValue
                        
                        cell.rightLabel.text = "\(reviews.count) Reviews"
                    }
                    
                    cell.selectionStyle = .None
                    
                    return cell
                }

            case .Reviews:
                
                if let reviews = reviews
                {
                    let review = reviews[indexPath.row] as ReviewResponse
                    
                    let cell: ReviewCell = tableView.dequeueReusableCellWithIdentifier("ReviewCell") as! ReviewCell
                    
                    cell.starView.rating = 0.0
                    cell.reviewTitleLabel.text = ""
                    cell.reviewContentLabel.text = ""
                    cell.sourceDomainLabel.text = ""
                    
                    if let rating = review.rating?.score?.doubleValue
                    {
                        cell.starView.rating = rating
                    }
                    else
                    {
                        cell.starView.hidden = true
                    }
                    
                    if let reviewTitle = review.title
                    {
                        cell.reviewTitleLabel.text = reviewTitle
                    }
                    
                    if let reviewDescription = review.description
                    {
                        cell.reviewContentLabel.text = reviewDescription
                    }
                    
                    if let author = review.author
                    {
                        cell.sourceDomainLabel.text = author
                    }
                    
                    cell.selectionStyle = .None
                    
                    return cell
                }
                
            default:
                return tableView.dequeueReusableCellWithIdentifier("UITableViewCell")! as UITableViewCell
            }
        }
        
        return tableView.dequeueReusableCellWithIdentifier("UITableViewCell")! as UITableViewCell
    }
    
    // MARK: Table View Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let tableSection: TableSection = TableSection(rawValue: indexPath.section)
        {
            switch tableSection {
            case .ProductHeader:
                return UITableViewAutomaticDimension
                
            case .OverallReviews:
                return 44.0
                
            case .Reviews:
                return UITableViewAutomaticDimension
                
            default:
                return 0.0
            }
        }
        
        return 0.0

    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == TableSection.ProductHeader.rawValue
        {
            return 169.0
        }
        else
        {
            return 80.0
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection {
            case .ProductHeader:
                return 0.01
//                
//            case .OverallReviews:
//                return 1
//                
//            case .Reviews:
//                return 8
                
            default:
                return 8.0
            }
        }
        
        return 8.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.HighlightedGrayColor
                
                if let productHeaderCell = cell as? SimpleProductHeaderCell
                {
                    productHeaderCell.productImageView.alpha = 0.5
                }
                else if let overallReviewCell = cell as? OverallReviewCell
                {
                    overallReviewCell.starView.alpha = 0.5
                }
                else if let reviewCell = cell as? ReviewCell
                {
                    reviewCell.starView.alpha = 0.5
                }
                
                }, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.whiteColor()
                
                if let productHeaderCell = cell as? SimpleProductHeaderCell
                {
                    productHeaderCell.productImageView.alpha = 1.0
                }
                else if let overallReviewCell = cell as? OverallReviewCell
                {
                    overallReviewCell.starView.alpha = 1.0
                }
                else if let reviewCell = cell as? ReviewCell
                {
                    reviewCell.starView.alpha = 1.0
                }
                
                }, completion: nil)
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowProductWebViewController"
        {
            if let currentProduct = self.product
            {
                if let destinationViewController = segue.destinationViewController as? ProductWebViewController
                {
                    if let url = currentProduct.outboundUrl
                    {
                        destinationViewController.webURL = NSURL(string: url)
                    }
                    
                    if let brandName = currentProduct.brand?.brandName
                    {
                        destinationViewController.brandName = brandName
                    }
                }
            }
        }
    }
}