//
//  ProductViewController.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

private enum TableSection: Int
{
    case ProductHeader = 0, Variant, Reviews, PriceHistory, Description, _Count
}

private enum Variant: Int
{
    case Style = 0, Size, _Count
}

class ProductViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var productIdentifier: String?
    
    var product: Product?
    
    var tempProductImages: Array<UIImage> = [UIImage(named: "blue-polo")!, UIImage(named: "blue-polo")!, UIImage(named: "blue-polo")!]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        hidesBottomBarWhenPushed = true
        
        if let item = product
        {
            title = item.title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.separatorColor = Color.clearColor()

        tableView.backgroundColor = Color.BackgroundGrayColor
    }
    
    // MARK: Actions
    @IBAction func buy(sender: AnyObject)
    {
        performSegueWithIdentifier("ShowProductWebViewController", sender: self)
    }
    
    // MARK: UITableView Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return TableSection._Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection {
            case .ProductHeader:
                return 1
                
            case .Variant:
                return 2
                
            case .Reviews:
                return 2
                
            case .PriceHistory:
                return 1
                
            case .Description:
                return 1
            default:
                return 0
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if let tableSection: TableSection = TableSection(rawValue: indexPath.section)
        {
            switch tableSection {
            case .ProductHeader:
                
                let cell: ProductHeaderCell = tableView.dequeueReusableCellWithIdentifier("ProductHeaderCell") as! ProductHeaderCell
                
                cell.setImageElements(tempProductImages)
                
                cell.brandLabel.text = "POLO RALPH LAUREN".uppercaseString
                cell.nameLabel.text = "Big Pony Polo"
                
                // Needs to handle if no sale price exists
                cell.largePriceLabel.attributedText = NSAttributedString(string: "$49.50", attributes: [NSForegroundColorAttributeName: Color.RedColor,
                    NSFontAttributeName: Font.OxygenBold(size: 17.0)])
                
                cell.smallPriceLabel.attributedText = NSAttributedString(string: "$89.50", attributes: [NSForegroundColorAttributeName: Color.DarkTextColor,
                    NSFontAttributeName: Font.OxygenRegular(size: 12.0),
                    NSStrikethroughStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)])
                
                cell.selectionStyle = .None
                
                return cell
                
            case .Variant:
                
                if let variant: Variant = Variant(rawValue: indexPath.row)
                {
                    switch variant {
                    case .Style:
                        
                        let cell: StyleCell = tableView.dequeueReusableCellWithIdentifier("StyleCell") as! StyleCell
                        
                        cell.styleNameLabel.text = "Navy Blue"
                        
                        cell.selectionStyle = .None
                        
                        
                        return cell

                    case .Size:
                        
                        let cell: SizeCell = tableView.dequeueReusableCellWithIdentifier("SizeCell") as! SizeCell
                        
                        cell.sizeLabel.text = "Large"
                        
                        cell.selectionStyle = .None
                        
                        return cell
                        
                    default:
                        log.debug("cellForRowAtIndexPath Error")
                        
                    }
                }

                
            case .Reviews:
                
                if indexPath.row == 0
                {
                    // Header Cell
                    let cell: OverallReviewCell = tableView.dequeueReusableCellWithIdentifier("OverallReviewCell") as! OverallReviewCell
                    
                    let rating: Float = 4.5
                    
                    cell.ratingLabel.text = String(rating)
                    
                    cell.starView.rating = Double(rating)
                    
                    let reviewCount: Int = 25
                    
                    cell.rightLabel.text = "See all \(reviewCount) reviews".uppercaseString
                    
                    return cell
                }
                else
                {
                    let cell: AlternateReviewCell = tableView.dequeueReusableCellWithIdentifier("AlternateReviewCell") as! AlternateReviewCell
                    
                    let rating: Float = 4.5
                    
                    cell.titleLabel.text = "Durability".uppercaseString
                    
                    cell.ratingLabel.text = String(rating)
                    
                    cell.starView.rating = Double(rating)
                    
                    return cell
                }
                
                //
                //        case .PriceHistory:
                //            return 1
                //            
                //        case .Description:
            //            return 1
            default:
                return tableView.dequeueReusableCellWithIdentifier("UITableViewCell")!
            }
        }
        
        return tableView.dequeueReusableCellWithIdentifier("UITableViewCell")!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let tableSection: TableSection = TableSection(rawValue: indexPath.section)
        {
           if tableSection == TableSection.ProductHeader
           {
                if cell is ProductHeaderCell
                {
                    cell.layoutIfNeeded()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if let headerView: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView
        {
            headerView.backgroundColor = Color.BackgroundGrayColor
        }
    }
    
    // MARK: UITableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let tableSection: TableSection = TableSection(rawValue: indexPath.section)
        {
            switch tableSection {
            case .Reviews:
                
                if indexPath.row == 0
                {
                    // Header Cell
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    performSegueWithIdentifier("ShowReviewsViewController", sender: self)
                }
                
            default:
                
                log.debug("didSelectRowAtIndexPath Error")
            }
        }
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let tableSection: TableSection = TableSection(rawValue: indexPath.section)
        {
            switch tableSection {
            case .ProductHeader:
                return 403.0
                
            case .Variant:
                return 48.0
                
            case .Reviews:
                if indexPath.row == 0
                {
                    return 48.0
                }
                else
                {
                    return 32.0
                }
                //
                //            case .PriceHistory:
                //                return 1
                //
                //            case .Description:
            //                return 1
            default:
                return 44.0
            }
        }
        
        return 44.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection {
            case .ProductHeader:
                return 8.0
                
            case .Variant:
                return 4.0
                
            case .Reviews:
                return 4.0
                
            case .PriceHistory:
                return 4.0
                
            case .Description:
                return 4.0
                
            default:
                return 8.0
            }
        }
        
        return 8.0

    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection {
            case .ProductHeader:
                return 4.0
                
            case .Variant:
                return 4.0
                
            case .Reviews:
                return 4.0
                
            case .PriceHistory:
                return 4.0
                
            case .Description:
                return 8.0
                
            default:
                return 8.0
            }
        }
        
        return 8.0
    }
    
    
}