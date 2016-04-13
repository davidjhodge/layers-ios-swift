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
    case ProductHeader = 0, OverallReview, Reviews, Count
}

class ReviewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Reviews".uppercaseString
        
        tableView.estimatedRowHeight = 128.0
        tableView.rowHeight = UITableViewAutomaticDimension
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
                
            case .OverallReview:
                return 1
                
            case .Reviews:
                return 8
                
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
                
//                cell.productImageView.image = UIImage(named: "blue-polo.png")
               
                cell.brandLabel.text = "Polo Ralph Lauren".uppercaseString
                
                cell.productNameLabel.text = "Big Pony Polo"
                
                return cell
                
            case .OverallReview:
                
                let cell: OverallReviewCell = tableView.dequeueReusableCellWithIdentifier("OverallReviewCell") as! OverallReviewCell
                
                cell.ratingLabel.text = "4.5"
                
                cell.starView.rating = 4.5
                
                cell.rightLabel.text = "Showing 1-8 of 25"
                
                return cell
                
            case .Reviews:
                
                let cell: ReviewCell = tableView.dequeueReusableCellWithIdentifier("ReviewCell") as! ReviewCell
                
                cell.starView.rating = 4.5
                
                cell.reviewTitleLabel.text = "Best shirt I've ever owned"
                
                cell.reviewContentLabel.text = "I was really impressed with how this shirt fit. I've never tried anything that fit this good. Especially not for the price. I'd definitely recommend this item to a friend."
                
                cell.sourceDomainLabel.text = "ralphlauren.com"
                
                return cell
                
            default:
                return tableView.dequeueReusableCellWithIdentifier("UITableViewCell")! as UITableViewCell
            }
        }
        
        return tableView.dequeueReusableCellWithIdentifier("UITableViewCell")! as UITableViewCell
    }
    
    // MARK: Table View Delegate
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection {
            case .ProductHeader:
                return 0.01
//                
//            case .OverallReview:
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
    
    
}