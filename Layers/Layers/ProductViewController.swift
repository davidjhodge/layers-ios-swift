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
                
                cell.brandLabel.text = "POLO RALPH LAUREN".uppercaseString
                cell.nameLabel.text = "Big Pony Polo"
                
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

                //
                //        case .Reviews:
                //            return 2
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
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if let headerView: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView
        {
            headerView.backgroundColor = Color.BackgroundGrayColor
        }
    }
    
    // MARK: UITableView Delegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let tableSection: TableSection = TableSection(rawValue: indexPath.section)
        {
            switch tableSection {
            case .ProductHeader:
                return 409.0
                
            case .Variant:
                return 48.0
                //
                //            case .Reviews:
                //                return 2
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