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

private enum VariantType: Int
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
    
    var productIdentifier: NSNumber?
    
    var product: ProductResponse?
    
    var tempProductImages: Array<UIImage> = [UIImage(named: "blue-polo")!, UIImage(named: "blue-polo")!, UIImage(named: "blue-polo")!]
    
    var selectedSegmentIndex: Int?
    
    var selectedVariant: Variant?
    
    var selectedSize: Size?
    
    //Dummy text fields to handle input views
    let styleTextField: UITextField = UITextField()
    let sizeTextField: UITextField = UITextField()

    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.separatorColor = Color.clearColor()

        tableView.backgroundColor = Color.BackgroundGrayColor
        
        spinner.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        
        setupPickers()
        
        reloadData()
    }
    
    func reloadData()
    {
        if let productId = productIdentifier
        {
            startNetworkActivitySpinners()
            
            LRSessionManager.sharedManager.loadProduct(productId, completionHandler: { (success, error, response) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.stopNetworkActivitySpinners()
                    })
                
                if success
                {
                    if let productResponse = response as? ProductResponse
                    {
                        self.product = productResponse
                        
                        // Set current Variant and size to the first index of each array by default
                        if let firstVariant = self.product?.variants?[0]
                        {
                            self.selectedVariant = firstVariant
                            
                            if let firstSize = firstVariant.sizes?[0]
                            {
                                self.selectedSize = firstSize
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.refreshUI()
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
        else
        {
            let alert = UIAlertController(title: "NO_PRODUCT_ID".localized, message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func refreshUI()
    {
        // Product Title
        if let product = self.product
        {
            if let productTitle = product.productName
            {
                self.title = productTitle
            }
        }
        
        tableView.reloadData()
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
    
    // MARK: Spinners
    func startNetworkActivitySpinners()
    {
        spinner.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func stopNetworkActivitySpinners()
    {
        spinner.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // MARK: Actions
    func buy(sender: AnyObject)
    {
        performSegueWithIdentifier("ShowProductWebViewController", sender: self)
    }
    
    func like(sender: AnyObject)
    {
        // Like API Call
        if sender is UIButton
        {
            let button = sender as! UIButton
            
            //This should be controlled by the model, not UI
            if button.selected == true
            {
                // User unliked item
                button.selected = false
            }
            else
            {
                // User liked item
                button.selected = true
            }
        }
    }
    
    func share()
    {
        if let url = product?.outboundUrl
        {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            presentViewController(activityViewController, animated: true, completion: {})
        }
        else
        {
            let alert = UIAlertController(title: "NO_SHARE_URL".localized, message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
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
        if product != nil
        {
            return TableSection._Count.rawValue
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let product = product
        {
            if let tableSection: TableSection = TableSection(rawValue: section)
            {
                switch tableSection {
                case .ProductHeader:
                    return 1
                    
                case .Variant:
                    return 2
                    
                case .Reviews:
                    
                    if let reviews = product.reviews
                    {
                        if reviews.count > 0
                        {
                            return 1
                        }
                    }
                    
                    return 0
                    
                case .PriceHistory:
                    return 1
                    
                case .Description:
                    return 0
                default:
                    return 0
                }
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if let product = self.product
        {
            if let tableSection: TableSection = TableSection(rawValue: indexPath.section)
            {
                switch tableSection {
                case .ProductHeader:
                    
                    let cell: ProductHeaderCell = tableView.dequeueReusableCellWithIdentifier("ProductHeaderCell") as! ProductHeaderCell
                    
                    cell.setImageElements(tempProductImages)
                    
                    if let brandName = product.brandName
                    {
                        cell.brandLabel.text = brandName.uppercaseString
                    }
                    
                    if let productName = product.productName
                    {
                        cell.nameLabel.text = productName
                    }
                    
                    // Price
                    let numberFormatter: NSNumberFormatter = NSNumberFormatter()
                    numberFormatter.numberStyle = .CurrencyStyle
                    
                    if let currentPrice = selectedSize?.prices?[0].price
                    {
                        let priceString = numberFormatter.stringFromNumber(currentPrice)!
                        
                        cell.largePriceLabel.attributedText = NSAttributedString(string: "\(priceString)", attributes: [NSForegroundColorAttributeName: Color.RedColor,
                            NSFontAttributeName: Font.OxygenBold(size: 17.0)])
                    }

                    if let retailPrice = selectedSize?.prices?[0].retailPrice
                    {
                        let priceString = numberFormatter.stringFromNumber(retailPrice)!

                        cell.smallPriceLabel.attributedText = NSAttributedString(string: "\(priceString)", attributes: [NSForegroundColorAttributeName: Color.DarkTextColor,
                            NSFontAttributeName: Font.OxygenRegular(size: 12.0),
                            NSStrikethroughStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)])
                    }
                    
                    // CTA
                    cell.ctaButton.addTarget(self, action: #selector(buy), forControlEvents: .TouchUpInside)
                    
                    // Share
                    cell.shareButton.setImage(UIImage(named: "share.png"), forState: .Normal)
                    cell.shareButton.setImage(UIImage(named: "share-filled.png"), forState: .Selected)
                    cell.shareButton.setImage(UIImage(named: "share-filled.png"), forState: .Highlighted)

                    cell.shareButton.addTarget(self, action: #selector(share), forControlEvents: .TouchUpInside)
                    
                    // Like
                    cell.likeButton.setImage(UIImage(named: "like.png"), forState: .Normal)
                    cell.likeButton.setImage(UIImage(named: "like-filled.png"), forState: .Selected)
                    cell.likeButton.setImage(UIImage(named: "like-filled.png"), forState: .Highlighted)

                    cell.likeButton.addTarget(self, action: #selector(like), forControlEvents: .TouchUpInside)

                    cell.selectionStyle = .None
                    
                    return cell
                    
                case .Variant:
                    
                    if let variant: VariantType = VariantType(rawValue: indexPath.row)
                    {
                        switch variant {
                        case .Style:
                            
                            let cell: StyleCell = tableView.dequeueReusableCellWithIdentifier("StyleCell") as! StyleCell
                            
                            if let variantName = selectedVariant?.styleName
                            {
                                cell.styleLabel.text = variantName
                            }
                            
                            cell.selectionStyle = .None
                            
                            return cell
                            
                        case .Size:
                            
                            let cell: SizeCell = tableView.dequeueReusableCellWithIdentifier("SizeCell") as! SizeCell
                            
                            if let sizeName = selectedSize?.sizeTitle
                            {
                                cell.sizeLabel.text = sizeName
                            }
                            
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
                        
                        if let firstRating = product.rating?[safe: 0]
                        {
                            if let ratingScore = firstRating.score, ratingTotal = firstRating.total
                            {
                                cell.ratingLabel.text = String(ratingScore)
                            }
                            
                            if let reviewCount = product.reviews?.count
                            {
                                cell.rightLabel.text = "See all \(reviewCount) reviews".uppercaseString
                            }
                        }
                        
                        return cell
                    }
                    
                case .PriceHistory:
                    
                    let cell: PriceGraphCell = tableView.dequeueReusableCellWithIdentifier("PriceGraphCell") as! PriceGraphCell
                    
                    //Temp
                    cell.setPercentChange(-7)
                    
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
                
                if let variant = VariantType(rawValue: indexPath.row)
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
                return 451.0
                
            case .Variant:
                return 48.0
                
            case .Reviews:
                if indexPath.row == 0
                {
                    return 48.0
                }
                
            case .PriceHistory:
                return 142.0
                
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
                
                if let reviews = product?.reviews
                {
                    if reviews.count > 0
                    {
                        return 4.0
                    }
                }
                
                return 0.01
                
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
                
                if let reviews = product?.reviews
                {
                    if reviews.count > 0
                    {
                        return 4.0
                    }
                }
                
                return 0.01
                
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
        
        if pickerView.tag == Picker.Style.rawValue
        {
            if let product = self.product
            {
                if let variants = product.variants
                {
                    return variants.count
                }
            }
        }
        else if pickerView.tag == Picker.Size.rawValue
        {
            if let currentVariant = selectedVariant
            {
                if let sizes = currentVariant.sizes
                {
                    return sizes.count
                }
            }
        }
        
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == Picker.Style.rawValue
        {
            if let product = self.product
            {
                if let variant = product.variants?[row]
                {
                    if let variantName = variant.styleName
                    {
                        return variantName
                    }
                }
            }
        }
        else if pickerView.tag == Picker.Size.rawValue
        {
            if let currentVariant = selectedVariant
            {
                if let size = currentVariant.sizes?[row]
                {
                    if let sizeName = size.sizeTitle
                    {
                        return sizeName
                    }
                }
            }
        }
        
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == Picker.Style.rawValue
        {
            //Should be index of product.styles
            if let product = self.product
            {
                if let variant = product.variants?[0]
                {
                    selectedVariant = variant
                }
            }
        }
        else if pickerView.tag == Picker.Size.rawValue
        {
            //Should be index of product.sizes
            if let currentVariant = selectedVariant
            {
                if let size = currentVariant.sizes?[row]
                {
                    selectedSize = size
                }
            }
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowReviewsViewController"
        {
            if let currentProduct = self.product
            {
                if let destinationViewController = segue.destinationViewController as? ReviewsViewController
                {
                    destinationViewController.productId = currentProduct.productId
                }
            }
            
//            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        }
        
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
                    
                    if let brand = currentProduct.brandName
                    {
                        destinationViewController.brandName = brand

                    }
                }
            }
        }
    }
    
}