//
//  ProductViewController.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import DeepLinkKit
import FBSDKCoreKit

private enum TableSection: Int
{
    case ProductHeader = 0, Variant, Reviews, PriceHistory, _Count
}

private enum VariantType: Int
{
    case Style = 0, Size, _Count
}

private enum Picker: Int
{
    case Style = 0, Size
}

class ProductViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, DPLTargetViewController
{
    @IBOutlet weak var tableView: UITableView!
        
    @IBOutlet var pickers: [UIPickerView]!
    
    @IBOutlet var pickerAccessoryView: PickerAccessoryView!
    
    var productIdentifier: NSNumber?
    
    var product: ProductResponse?
    
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
        
        if let productId = productIdentifier
        {
            FBSDKAppEvents.logEvent("Product Views", parameters: ["Product ID":productId.stringValue])
        }

        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.separatorColor = Color.clearColor()

        tableView.backgroundColor = Color.BackgroundGrayColor
        
        spinner.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        
        if navigationController?.navigationBarHidden == true
        {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
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
                        var variant: Variant?
                        
                        if let variants = self.product?.variants
                        {
                            // Returns a variant that matches the color
                            if let matchingVariant = Variant.variantMatchingFilterColorsInVariants(variants)
                            {
                                variant = matchingVariant
                            }
                        }
                        
                        if variant == nil
                        {
                            if let firstVariant = self.product?.variants?[safe: 0]
                            {
                                variant = firstVariant
                            }
                        }
                        
                        if let variant = variant
                        {
                            self.selectedVariant = variant
                            
                            if let firstSize = variant.sizes?[0]
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
        for (index, picker) in pickers.enumerate()
        {
            picker.backgroundColor = Color.BackgroundGrayColor
            
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
        FBSDKAppEvents.logEvent("Product Page CTA Taps")
        
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
        FBSDKAppEvents.logEvent("Product Page Share Taps")

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            if let url = self.product?.outboundUrl
            {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                self.presentViewController(activityViewController, animated: true, completion: {})
            }
            else
            {
                let alert = UIAlertController(title: "NO_SHARE_URL".localized, message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    func createSaleAlert()
    {
        if let productId = productIdentifier
        {
            FBSDKAppEvents.logEvent("Product Page Create Sale Alert Taps", parameters: ["ProductID":productId])
        }

        if LRSessionManager.sharedManager.userHasEnabledNotifications()
        {
            if let productId = productIdentifier
            {
                LRSessionManager.sharedManager.createSaleAlert(productId, completionHandler: { (success, error, response) -> Void in
                    
                    if success
                    {
                        // Post Notification
                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kSaleAlertCreatedNotification, object: nil))
                        
                        // Show Success HUD
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                            hud.mode = .CustomView
                            hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                            
                            hud.labelText = "Sale Alert Created"
                            hud.labelFont = Font.OxygenBold(size: 17.0)
                            hud.hide(true, afterDelay: 1.5)
                        })
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
        }
        else
        {
            LRSessionManager.sharedManager.registerForRemoteNotificationsIfNeeded()
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
    
    // MARK: Analytics
    func photoTap()
    {
        if let product = product
        {
            if let productId = product.productId,
            let productName = product.productName,
            let category = product.category?.categoryName
            {
                FBSDKAppEvents.logEvent("Product Page Photo Taps", parameters: ["Product ID":productId, "Product Name":productName, "Category Name":category])
            }
        }
    }
    
    func brandTap()
    {
        
    }
    
    // MARK: Picker Actions
    func pickerDidFinish()
    {
        tableView.reloadData()
        
        view.endEditing(true)
    }
    
    func pickerDidCancel()
    {
        view.endEditing(true)
    }
    
    // MARK: Deep Linking
    
    func configureWithDeepLink(deepLink: DPLDeepLink!) {
        
        if let key = deepLink.routeParameters["product_id"] as? String
        {
            if let productId = Int(key)
            {
                productIdentifier = NSNumber(integer: productId)
            }
        }
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
                    
                    if let reviewCount = product.reviewCount?.integerValue
                    {
                        if reviewCount > 0
                        {
                            return 1

                        }
                    }
                    
                    return 0
                    
                case .PriceHistory:
                    return 1

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
                    
                    cell.brandLabel.text = ""
                    
                    cell.nameLabel.text = ""
                    
                    var productImages: Array<NSURL> = Array<NSURL>()
                    
                    if let imageDict = selectedVariant?.images?[0]
                    {
                        if let primaryUrl = imageDict.primaryUrl
                        {   
                            let resizedPrimaryUrl = NSURL.imageAtUrl(primaryUrl, imageSize: ImageSize.kImageSize224)
                            
                            productImages.append(resizedPrimaryUrl)
                            
                            if let alternateUrls = imageDict.alternateUrls
                            {
                                for alternateUrl in alternateUrls
                                {
                                    let resizedAlternateUrl = NSURL.imageAtUrl(alternateUrl, imageSize: ImageSize.kImageSize224)
                                    
                                    productImages.append(resizedAlternateUrl)
                                }
                            }
                        }
                    }
                    
                    cell.setImageElements(productImages)
                    
                    // For Analytics
                    cell.scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoTap)))
                    
                    if let brandName = product.brand?.brandName
                    {
                        cell.brandLabel.text = brandName.uppercaseString
                    }
                    
                    if let productName = product.productName
                    {
                        cell.nameLabel.text = productName
                    }
                    
                    cell.largePriceLabel.text = ""
                    cell.smallPriceLabel.text = ""
                    
                    var currentPrice: NSNumber?
                    
                    // If a coupon price exists, show it instead of the default price
                    if let altCouponPrice = selectedSize?.altPrice?.priceAfterCoupon
                    {
                        currentPrice = altCouponPrice
                    }
                    else if let currPrice = selectedSize?.price?.price
                    {
                        currentPrice = currPrice
                    }
                    
                    if let currentPrice = currentPrice
                    {
                        if let retailPrice = selectedSize?.price?.retailPrice
                        {
                            if (currentPrice.floatValue != retailPrice.floatValue)
                            {
                                cell.largePriceLabel.attributedText = NSAttributedString.priceStringWithSalePrice(currentPrice, size: 17.0)
                                
                                cell.smallPriceLabel.attributedText = NSAttributedString.priceStringWithRetailPrice(retailPrice, size: 12.0, strikethrough: true)
                            }
                            else
                            {
                                cell.largePriceLabel.attributedText = NSAttributedString.priceStringWithRetailPrice(currentPrice, size: 17.0, strikethrough: false)
                            }
                        }
                        else
                        {
                            cell.largePriceLabel.attributedText = NSAttributedString.priceStringWithRetailPrice(currentPrice, size: 17.0, strikethrough: false)
                        }
                    }
                    
                    cell.ctaButton.setTitle("View Online".uppercaseString, forState: .Normal)
                    cell.ctaButton.addTarget(self, action: #selector(buy), forControlEvents: .TouchUpInside)
                    
                    cell.shareButton.setImage(UIImage(named: "share"), forState: .Normal)
                    cell.shareButton.setImage(UIImage(named: "share-filled"), forState: .Highlighted)
                    cell.shareButton.addTarget(self, action: #selector(share), forControlEvents: .TouchUpInside)
                    
                    cell.selectionStyle = .None
                    
                    return cell
                    
                case .Variant:
                    
                    if let variant: VariantType = VariantType(rawValue: indexPath.row)
                    {
                        switch variant {
                        case .Style:
                            
                            let cell: StyleCell = tableView.dequeueReusableCellWithIdentifier("StyleCell") as! StyleCell
                            
                            cell.styleLabel.text = ""
                            
                            if let variantName = selectedVariant?.styleName
                            {
                                cell.styleLabel.text = variantName.capitalizedString
                            }
                            
                            if let selectedColor = selectedVariant?.color
                            {
                                if let red = selectedColor.red?.floatValue, blue = selectedColor.blue?.floatValue, green = selectedColor.green?.floatValue
                                {
                                    cell.colorSwatchView.backgroundColor = UIColor(colorLiteralRed: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
                                }
                            }
                            
                            cell.selectionStyle = .None
                            
                            return cell
                            
                        case .Size:
                            
                            let cell: SizeCell = tableView.dequeueReusableCellWithIdentifier("SizeCell") as! SizeCell
                            
                            cell.sizeLabel.text = ""

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
                        
                        if let firstRating = product.rating
                        {
                            if let ratingScore = firstRating.score?.integerValue,
                                let ratingTotal = firstRating.total?.integerValue
                            {
                                cell.ratingLabel.text = "\(ratingScore) / \(ratingTotal)"
                            }
                            
                            if let reviewCount = product.reviewCount
                            {
                                if reviewCount.integerValue == 1
                                {
                                    cell.rightLabel.text = "See \(reviewCount) review".uppercaseString
                                }
                                else if reviewCount.integerValue > 0
                                {
                                    cell.rightLabel.text = "See \(reviewCount) reviews".uppercaseString
                                }
                                else
                                {
                                    cell.rightLabel.text = "No Reviews".uppercaseString
                                    
                                    // Just in case
                                    cell.userInteractionEnabled = false
                                }
                            }
                        }
                        
                        return cell
                    }
                    
                case .PriceHistory:
                    
                    let cell: PriceGraphCell = tableView.dequeueReusableCellWithIdentifier("PriceGraphCell") as! PriceGraphCell
                    
                    //Temp
                    cell.setPercentChange(-7)
                    
                    cell.selectionStyle = .None
                    
                    if product.isWatching
                    {
                        cell.createSaleAlertButton.setTitle("Watching".uppercaseString, forState: .Normal)
                    }
                    else
                    {
                        cell.createSaleAlertButton.setTitle("Create a Price Alert".uppercaseString, forState: .Normal)
                    }
                    
                    cell.createSaleAlertButton.addTarget(self, action: #selector(createSaleAlert), forControlEvents: .TouchUpInside)
                    
                    return cell
                    
                default:
                    return UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
                }
            }
        }
        
        return UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
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
                        
                        if let product = product
                        {
                            if let productId = product.productId,
                                let productName = product.productName,
                                let category = product.category?.categoryName
                            {
                                FBSDKAppEvents.logEvent("Product Page Style Taps", parameters: ["ProductID": productId, "Product Name": productName, "Category":category])
                            }
                        }
                    }
                    else if variant == .Size
                    {
                        showPicker(sizeTextField)
                        
                        if let product = product
                        {
                            if let productId = product.productId,
                                let productName = product.productName,
                                let category = product.category?.categoryName
                            {
                                FBSDKAppEvents.logEvent("Product Page Size Taps", parameters: ["ProductID": productId, "Product Name": productName, "Category":category])
                            }
                        }
                    }
                }
                
            case .Reviews:
                
                if indexPath.row == 0
                {
                    // Header Cell
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    if let reviewsVc = storyboard.instantiateViewControllerWithIdentifier("ReviewsViewController") as? ReviewsViewController, let currentProduct = self.product
                    {
                        reviewsVc.productId = currentProduct.productId
                        
                        reviewsVc.product = product
                        
                        navigationController?.pushViewController(reviewsVc, animated: true)
                    }
                }
                
            default:
                
                break
            }
        }
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let tableSection: TableSection = TableSection(rawValue: indexPath.section)
        {
            switch tableSection {
            case .ProductHeader:
//                return 451.0
                return UITableViewAutomaticDimension
                
            case .Variant:
                return 48.0
                
            case .Reviews:
                if indexPath.row == 0
                {
                    return 48.0
                }
                
            case .PriceHistory:
                return UITableViewAutomaticDimension
                
            default:
                return 44.0
            }
        }
        
        return 44.0
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == TableSection.ProductHeader.rawValue
        {
            return 451.0
        }
            else if indexPath.section == TableSection.PriceHistory.rawValue
        {
            return 142.0
        }
        else
        {
            return 48.0
        }
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
                
                if let reviewCount = product?.reviewCount?.integerValue
                {
                    if reviewCount > 0
                    {
                        return 4.0
                    }
                }

                return 0.01
                
            case .PriceHistory:
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
                
                if let reviewCount = product?.reviewCount?.integerValue
                {
                    if reviewCount > 0
                    {
                        return 4.0
                    }
                }
                
                return 0.01
                
            case .PriceHistory:
                return 8.0

            default:
                return 8.0
            }
        }
        
        return 8.0
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == TableSection.Variant.rawValue
        {
            if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)
            {
                UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                    
                    cell.backgroundColor = Color.HighlightedGrayColor
                    
                    if let styleCell = cell as? StyleCell
                    {
                        styleCell.colorSwatchView.alpha = 0.5
                    }
                    
                    }, completion: nil)
            }
        }
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)
        {
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.whiteColor()
                
                if let styleCell = cell as? StyleCell
                {
                    styleCell.colorSwatchView.alpha = 1.0
                }
                
                }, completion: nil)
        }
    }
    
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
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        if view == nil
        {
            // Remove selection indicators
            pickerView.subviews[1].hidden = false
            pickerView.subviews[2].hidden = false
            pickerView.subviews[3].hidden = true
            
            if let pickerRow: PickerRow = NSBundle.mainBundle().loadNibNamed("PickerRow", owner: self, options: nil)[0] as? PickerRow
            {
                if pickerView.tag == Picker.Style.rawValue
                {
                    if let product = self.product
                    {
                        if let variant = product.variants?[row]
                        {
                            if let variantName = variant.styleName
                            {
                                pickerRow.textLabel.text = variantName.capitalizedString
                            }
                            
                            if let color = variant.color
                            {
                                if let red = color.red?.floatValue, blue = color.blue?.floatValue, green = color.green?.floatValue
                                {
                                    pickerRow.colorSwatchView.backgroundColor = UIColor(colorLiteralRed: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
                                }
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
                                pickerRow.textLabel.text = sizeName.capitalizedString
                            }
                            
                            pickerRow.colorSwatchView.hidden = true
                        }
                    }
                }
                
                pickerRow.bounds = CGRectMake(pickerRow.bounds.origin.x, pickerRow.bounds.origin.y, UIScreen .mainScreen().bounds.width, pickerRow.bounds.size.height)
                
                return pickerRow
            }
            
            return UIView()
        }
        else
        {
            if let reuseView = view
            {
                return reuseView
            }
        }

        return UIView()
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        return view.bounds.size.width
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 48.0
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
                        return variantName.capitalizedString
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
                if let variant = product.variants?[row]
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
                    
                    destinationViewController.product = product
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
                    
                    if let coupon = selectedSize?.altPrice?.couponCode
                    {
                        destinationViewController.couponCode = coupon
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