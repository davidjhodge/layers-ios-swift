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

private enum InfoType: Int
{
    case Features = 0, Description
}

private enum Picker: Int
{
    case Style = 0, Size
}

class ProductViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
        
    @IBOutlet var pickers: [UIPickerView]!
    
    @IBOutlet var pickerAccessoryView: PickerAccessoryView!
    
    var productIdentifier: String?
    
    var product: Product?
    
    var tempProductImages: Array<UIImage> = [UIImage(named: "blue-polo")!, UIImage(named: "blue-polo")!, UIImage(named: "blue-polo")!]
    
    var selectedSegmentIndex: Int?
    
    var selectedStyle: String?
    
    var selectedSize: String?
    
    //Dummy text fields to handle input views
    let styleTextField: UITextField = UITextField()
    let sizeTextField: UITextField = UITextField()

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
        
        setupPickers()
        
        reloadData()
    }
    
    func reloadData()
    {
        title = "Big Pony Polo"
    }
    
    func setupPickers()
    {
//        for (index, imageView) in imageViews.enumerate()
        for (index, picker) in pickers.enumerate()
        {
            if index == Picker.Style.rawValue
            {
                picker.tag = Picker.Style.rawValue
                
                styleTextField.inputView = picker
                styleTextField.inputAccessoryView = pickerAccessoryView
                
                view.addSubview(styleTextField)
                styleTextField.hidden = true
            }
            else if index == Picker.Size.rawValue
            {
                picker.tag = Picker.Size.rawValue
                
                sizeTextField.inputView = picker
                sizeTextField.inputAccessoryView = pickerAccessoryView
                
                view.addSubview(sizeTextField)
                sizeTextField.hidden = true
            }
            
            picker.dataSource = self
            picker.delegate = self
        }
        
        pickerAccessoryView.doneButton.addTarget(self, action: #selector(pickerDidFinish), forControlEvents: .TouchUpInside)
        
        pickerAccessoryView.cancelButton.addTarget(self, action: #selector(pickerDidCancel), forControlEvents: .TouchUpInside)
    }
    
    // MARK: Actions
    @IBAction func buy(sender: AnyObject)
    {
        performSegueWithIdentifier("ShowProductWebViewController", sender: self)
    }
    
    func createPriceAlert()
    {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        if let priceAlertVC: CreatePriceAlertViewController = storyboard.instantiateViewControllerWithIdentifier("CreatePriceAlertViewController") as? CreatePriceAlertViewController
        {
            presentViewController(priceAlertVC, animated: true, completion: nil)
        }

    }
    
    func showPicker(textField: UITextField?)
    {
        // If an existing picker is already in view, remove it
        
        if let textField = textField
        {
            if textField.isFirstResponder()
            {
                textField.resignFirstResponder()
            }

            textField.becomeFirstResponder()
        }
    }
    
    // MARK: Picker Actions
    func pickerDidFinish()
    {
        view.endEditing(true)
    }
    
    func pickerDidCancel()
    {
        view.endEditing(true)
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
                return 1
                
            case .PriceHistory:
                return 1
                
            case .Description:
                return 0
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
                        
                        cell.styleLabel.text = "Navy Blue"
                        
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
                
            case .PriceHistory:
                
                let cell: PriceGraphCell = tableView.dequeueReusableCellWithIdentifier("PriceGraphCell") as! PriceGraphCell
                
                cell.priceLabel.attributedText = NSAttributedString.priceStringWithRetailPrice(8950, salePrice: 4950)
                
                cell.adviceLabel.text = "ADVICE: WATCH"
                
                cell.selectionStyle = .None
                
                cell.createPriceAlertButton.addTarget(self, action: #selector(createPriceAlert), forControlEvents: .TouchUpInside)
                
                return cell
                
//            case .Description:
            
//                let cell: FeaturesCell = tableView.dequeueReusableCellWithIdentifier("FeaturesCell") as! FeaturesCell
//                
//                cell.textView.text = "This is a sample description of a completely random product that I don't quite now of yet."
//                
//                cell.selectionStyle = .None
//                
//                return cell
                
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
            case .Variant:
                
                if let variant = Variant(rawValue: indexPath.row)
                {
                    if variant == .Style
                    {
                        showPicker(styleTextField)
                    }
                    else if variant == .Size
                    {
                        showPicker(sizeTextField)
                    }
                }
                
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
                
            case .PriceHistory:
                return 326.0
                
            case .Description:
                return 178.0
//                return UITableViewAutomaticDimension
                
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
                return 0.01
                
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
                return 4.0
                
            default:
                return 8.0
            }
        }
        
        return 8.0
    }
    
    // MARK: Picker View Data Source
    // MARK: Picker View
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == Picker.Style.rawValue
        {
            return "Navy Blue"
        }
        else if pickerView.tag == Picker.Size.rawValue
        {
            return "Large"
        }
        
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == Picker.Style.rawValue
        {
            //Should be index of product.styles
            selectedStyle = "selectedStyle"
        }
        else if pickerView.tag == Picker.Size.rawValue
        {
            //Should be index of product.sizes
            selectedSize = "selectedSize"
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowReviewsViewController"
        {
//            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        }
    }
    
}