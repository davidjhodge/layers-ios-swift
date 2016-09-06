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
import IDMPhotoBrowser

private enum TableSection: Int
{
    case ProductHeader = 0, Variant, _Count
}

private enum VariantType: Int
{
    case Style = 0, Size, MoreDetails, _Count
}

private enum Picker: Int
{
    case Style = 0, Size
}

class ProductViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, DPLTargetViewController, PaginatedImageViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
        
    @IBOutlet var pickers: [UIPickerView]!
    
    @IBOutlet var pickerAccessoryView: PickerAccessoryView!
    
    var productIdentifier: NSNumber?
    
    var product: Product?
    
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
        
        tableView.delaysContentTouches = false
        
        spinner.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        
        if navigationController?.navigationBarHidden == true
        {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        setupPickers()
        
        reloadProduct()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func reloadProduct()
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
                    if let product = response as? Product
                    {
                        self.product = product
                        
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
                            
                            if let firstSize = variant.sizes?[safe: 0]
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
            if let productTitle = product.unbrandedName
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
        
        if let currentProduct = self.product
        {
            if let url = currentProduct.outboundUrl
            {
                showWebBrowser(url)
            }
            
            if let productName = currentProduct.brandedName,
                let productId = currentProduct.productId
            {
                FBSDKAppEvents.logEvent("Product Page Clickthrough Web Views", parameters: ["Product Name":productName, "Product ID":productId])
            }
        }
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
    
    // MARK: Paginated Image View Delegate
    func showPhotoFullscreen(imageView: UIImageView, photos: Array<NSURL>, selectedIndex: Int)
    {
        // Analytics
        if let product = product
        {
            if let productId = product.productId,
                let productName = product.brandedName,
                let category = product.categories?[safe: 0]?.name
            {
                FBSDKAppEvents.logEvent("Product Page Photo Taps", parameters: ["Product ID":productId, "Product Name":productName, "Category Name":category])
            }
        }
        
        // Show Photo
        let photoBrowser = IDMPhotoBrowser(photoURLs: photos, animatedFromView: imageView)
        
        photoBrowser.scaleImage = imageView.image
        
        photoBrowser.view.tintColor = Color.whiteColor()

        photoBrowser.displayArrowButton = false
        
        photoBrowser.displayCounterLabel = false
        
        photoBrowser.forceHideStatusBar = true
        
        photoBrowser.useWhiteBackgroundColor = false
        
        photoBrowser.usePopAnimation = true
        
        photoBrowser.displayActionButton = false
        
        // Show Done Button
        photoBrowser.displayDoneButton = true
        
        photoBrowser.setInitialPageIndex(UInt(selectedIndex))
        
        presentViewController(photoBrowser, animated: true, completion: nil)
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
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection {
            case .ProductHeader:
                return 1
                
            case .Variant:
                return 3
                
            default:
                return 0
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
                    
                    cell.delegate = self
                    
                    // Set images

                    var productImages: Array<NSURL> = Array<NSURL>()

                    // Append primary image
                    if let primaryImageResolutions = product.images?.primaryImageUrls
                    {
                        if let imageIndex = primaryImageResolutions.indexOf({ $0.sizeName == "IPhone" })
                        {
                            if let primaryImage: Image = primaryImageResolutions[safe: imageIndex]
                            {
                                if let imageUrl = primaryImage.url
                                {
                                    productImages.append(imageUrl)
                                }
                            }
                        }
                    }
                    
                    // Append alternate images
                    if let alternateImages = product.images?.alternateImages
                    {
                        for imageResolutions in alternateImages
                        {
                            if let imageIndex = imageResolutions.indexOf({ $0.sizeName == "IPhone" })
                            {
                                if let altImage: Image = imageResolutions[safe: imageIndex]
                                {
                                    if let imageUrl = altImage.url
                                    {
                                        productImages.append(imageUrl)
                                    }
                                }
                            }
                        }
                    }
            
                    cell.setImageElements(productImages)
                    
                    if let brandName = product.brand?.name
                    {
                        cell.brandLabel.text = brandName.uppercaseString
                    }
                    
                    if let productName = product.unbrandedName
                    {
                        cell.nameLabel.text = productName
                    }
                    
                    cell.largePriceLabel.text = ""
                    cell.smallPriceLabel.text = ""
                    
                    var currentPrice: NSNumber?
                    
                    // If a coupon price exists, show it instead of the default price
                    if let currPrice = product.altPrice?.salePrice
                    {
                        currentPrice = currPrice
                    }
                    
                    if let currentPrice = currentPrice
                    {
                        if let retailPrice = product.price?.price
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
                    
                    cell.ctaButton.setAttributedTitle(NSAttributedString(string: "View Online".uppercaseString, attributes: FontAttributes.filledButtonAttributes), forState: [.Normal, .Highlighted])
                                        
                    cell.ctaButton.addTarget(self, action: #selector(buy), forControlEvents: .TouchUpInside)

                    cell.ctaButton.setBackgroundColor(Color.NeonBlueColor, forState: .Normal)
                    cell.ctaButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .Highlighted)
    
                    cell.ctaButton.adjustsImageWhenHighlighted = false
                    
                    cell.selectionStyle = .None
                    
                    return cell
                    
                case .Variant:
                    
                    if let variant: VariantType = VariantType(rawValue: indexPath.row)
                    {
                        switch variant {
                        case .Style:
                            
                            let cell: StyleCell = tableView.dequeueReusableCellWithIdentifier("StyleCell") as! StyleCell
                            
                            cell.styleLabel.text = ""
                            
                            if let variantName = selectedVariant?.color
                            {
                                cell.styleLabel.text = variantName.capitalizedString
                            }
                            
                            // Should set color swatches here
                            
                            cell.selectionStyle = .None
                            
                            return cell
                            
                        case .Size:
                            
                            let cell: SizeCell = tableView.dequeueReusableCellWithIdentifier("SizeCell") as! SizeCell
                            
                            cell.sizeLabel.text = ""
                            
                            if let sizeName = selectedSize?.sizeName
                            {
                                cell.sizeLabel.text = sizeName
                            }
                            
                            cell.selectionStyle = .None
                            
                            return cell
                            
                            
                        case .MoreDetails:
                            
                            let cell: MoreDetailsCell = tableView.dequeueReusableCellWithIdentifier("MoreDetailsCell") as! MoreDetailsCell
                            
                            cell.moreDetailsLabel.attributedText = NSAttributedString(string: "View More Details".uppercaseString, attributes: [NSForegroundColorAttributeName:Color.GrayColor,
                                NSFontAttributeName:Font.PrimaryFontSemiBold(size: 14.0),
                                NSKernAttributeName:1.5])
                            
                            return cell
                            
                        default:
                            log.debug("cellForRowAtIndexPath Error")
                            
                        }
                    }
                    
                default:
                    return UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
                }
            }
        }
        
        return UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
    }
    
    func highlightCTAButton(sender: UIButton)
    {
        sender.backgroundColor = Color.NeonBlueColor
        sender.titleLabel?.textColor = Color.whiteColor()
    }
    
    func unhighlightCTAButton(sender: UIButton)
    {
        sender.backgroundColor = Color.NeonBlueHighlightedColor
        sender.titleLabel?.textColor = Color.whiteColor()
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
                                let productName = product.brandedName,
                                let category = product.categories?[safe: 0]?.name
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
                                let productName = product.brandedName,
                                let category = product.categories?[safe: 0]?.name
                            {
                                FBSDKAppEvents.logEvent("Product Page Size Taps", parameters: ["ProductID": productId, "Product Name": productName, "Category":category])
                            }
                        }
                    }
                    else if variant == .MoreDetails
                    {
                        // Present More Details View Controller
                        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        
                        if let moreDetailsVc = storyboard.instantiateViewControllerWithIdentifier("MoreDetailsViewController") as? MoreDetailsViewController
                        {
                            if let product = product
                            {
                                moreDetailsVc.product = product
                            }
                            
                            navigationController?.pushViewController(moreDetailsVc, animated: true)
                        }
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
//                return 398.0
                return UITableViewAutomaticDimension
                
            case .Variant:
                return 48.0
                
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
                
            default:
                return 4.0
            }
        }
        
        return 4.0

    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection {
            case .ProductHeader:
                return 4.0
                
            case .Variant:
                return 4.0
            
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
            pickerView.subviews[1].hidden = true
            pickerView.subviews[2].hidden = true
            
            if let pickerRow: PickerRow = NSBundle.mainBundle().loadNibNamed("PickerRow", owner: self, options: nil)[0] as? PickerRow
            {
                if pickerView.tag == Picker.Style.rawValue
                {
                    if let product = self.product
                    {
                        if let variant = product.variants?[row]
                        {
                            if let variantName = variant.color
                            {
                                pickerRow.textLabel.text = variantName.capitalizedString
                            }
                            
                            // Set color
                            
//                            if let color = variant.color
//                            {
//                                if let red = color.red?.floatValue, blue = color.blue?.floatValue, green = color.green?.floatValue
//                                {
//                                    pickerRow.colorSwatchView.backgroundColor = UIColor(colorLiteralRed: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
//                                }
//                            }
                        }
                    }
                }
                else if pickerView.tag == Picker.Size.rawValue
                {
                    if let currentVariant = selectedVariant
                    {
                        if let size = currentVariant.sizes?[row]
                        {
                            if let sizeName = size.sizeName
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
                    if let variantName = variant.color
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
                    if let sizeName = size.sizeName
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
                if let variant = product.variants?[safe: row]
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
                if let size = currentVariant.sizes?[safe: row]
                {
                    selectedSize = size
                }
            }
        }
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
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}