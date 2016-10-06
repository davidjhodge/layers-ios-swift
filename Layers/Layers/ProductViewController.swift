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
    case productHeader = 0, variant, _Count
}

private enum VariantType: Int
{
    case style = 0, size, moreDetails, _Count
}

private enum Picker: Int
{
    case style = 0, size
}

class ProductViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DPLTargetViewController, PaginatedImageViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var productIdentifier: NSNumber?
    
    var product: Product?
    
    var selectedSegmentIndex: Int?
    
    var selectedVariant: Variant?
    
    var selectedSize: Size?
    
    //Dummy text fields to handle input views
    let styleTextField: UITextField = UITextField()
    let sizeTextField: UITextField = UITextField()

    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
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
        
        // Change status bar style to .LightContent
        navigationController?.navigationBar.barStyle = .black

        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.separatorColor = Color.clear

        tableView.backgroundColor = Color.BackgroundGrayColor
        
        tableView.delaysContentTouches = false
        
        spinner.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        
        if navigationController?.isNavigationBarHidden == true
        {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        reloadProduct()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func reloadProduct()
    {
        if let productId = productIdentifier
        {
            startNetworkActivitySpinners()
            
            LRSessionManager.sharedManager.loadProduct(productId, completionHandler: { (success, error, response) -> Void in
                
                DispatchQueue.main.async(execute: { () -> Void in
                    
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
                        
                        if let currentVariants = product.variants
                        {
                            VariantColors.analyzeVariantsAndApplyDominantColors(currentVariants, completionBlock: { (variants) -> Void in
                              
                                if let newVariants = variants
                                {
                                    product.variants = newVariants
                                    
                                    if let newDominantColor = product.variants?[safe: 0]?.dominantColor
                                    {
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            
                                            self.view.backgroundColor = newDominantColor
                                        })
                                    }
                                }
                            })
                        }
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            
                            self.refreshUI()
                        })
                    }
                }
                else
                {
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            })
        }
        else
        {
            let alert = UIAlertController(title: "NO_PRODUCT_ID".localized, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
    
    // MARK: Spinners
    func startNetworkActivitySpinners()
    {
        spinner.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func stopNetworkActivitySpinners()
    {
        spinner.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // MARK: Actions
    func buy(_ sender: AnyObject)
    {
        FBSDKAppEvents.logEvent("Product Page CTA Taps")
        
        if let currentProduct = self.product
        {
            if let url = currentProduct.outboundUrl
            {
                showWebBrowser(url as URL)
            }
            
            if let productName = currentProduct.brandedName,
                let productId = currentProduct.productId
            {
                FBSDKAppEvents.logEvent("Product Page Clickthrough Web Views", parameters: ["Product Name":productName, "Product ID":productId])
            }
        }
    }
    
    func like(_ sender: AnyObject)
    {
        // Like API Call
        if sender is UIButton
        {
            let button = sender as! UIButton
            
            //This should be controlled by the model, not UI
            if button.isSelected == true
            {
                // User unliked item
                button.isSelected = false
            }
            else
            {
                // User liked item
                button.isSelected = true
            }
        }
    }
    
    func share()
    {
        FBSDKAppEvents.logEvent("Product Page Share Taps")

        DispatchQueue.main.async(execute: { () -> Void in
            
            if let url = self.product?.outboundUrl
            {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: {})
            }
            else
            {
                let alert = UIAlertController(title: "NO_SHARE_URL".localized, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    // MARK: Analytics
    func brandTap()
    {
        
    }
    
    // MARK: Deep Linking
    
    func configure(with deepLink: DPLDeepLink!) {
        
        if let key = deepLink.routeParameters["product_id"] as? String
        {
            if let productId = Int(key)
            {
                productIdentifier = NSNumber(value: productId as Int)
            }
        }
    }
    
    // MARK: Paginated Image View Delegate
    func showPhotoFullscreen(_ imageView: UIImageView, photos: Array<URL>, selectedIndex: Int)
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
        let photoBrowser = IDMPhotoBrowser(photoURLs: photos, animatedFrom: imageView)
        
        photoBrowser?.scaleImage = imageView.image
        
        photoBrowser?.view.tintColor = Color.white

        photoBrowser?.displayArrowButton = false
        
        photoBrowser?.displayCounterLabel = false
        
        photoBrowser?.forceHideStatusBar = true
        
        photoBrowser?.useWhiteBackgroundColor = false
        
        photoBrowser?.usePopAnimation = true
        
        photoBrowser?.displayActionButton = false
        
        // Show Done Button
        photoBrowser?.displayDoneButton = true
        
        photoBrowser?.setInitialPageIndex(UInt(selectedIndex))
        
        present(photoBrowser!, animated: true, completion: nil)
    }
    
    // MARK: UITableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if product != nil
        {
            return TableSection._Count.rawValue
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection {
            case .productHeader:
                return 1
                
            case .variant:
                return 3
                
            default:
                return 0
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let product = self.product
        {
            if let tableSection: TableSection = TableSection(rawValue: (indexPath as NSIndexPath).section)
            {
                switch tableSection {
                case .productHeader:
                    
                    let cell: ProductHeaderCell = tableView.dequeueReusableCell(withIdentifier: "ProductHeaderCell") as! ProductHeaderCell
                    
                    cell.brandLabel.text = ""
                    
                    cell.nameLabel.text = ""
                    
                    cell.delegate = self
                    
                    // Set images

                    var productImages: Array<URL> = Array<URL>()

                    // Append primary image
                    if let primaryImageResolutions = product.images?.primaryImageUrls
                    {
                        if let imageIndex = primaryImageResolutions.index(where: { $0.sizeName == "IPhone" })
                        {
                            if let primaryImage: Image = primaryImageResolutions[safe: imageIndex]
                            {
                                if let imageUrl = primaryImage.url
                                {
                                    productImages.append(imageUrl as URL)
                                }
                            }
                        }
                    }
                    
                    // Append alternate images
                    if let alternateImages = product.images?.alternateImages
                    {
                        for imageResolutions in alternateImages
                        {
                            if let imageIndex = imageResolutions.index(where: { $0.sizeName == "IPhone" })
                            {
                                if let altImage: Image = imageResolutions[safe: imageIndex]
                                {
                                    if let imageUrl = altImage.url
                                    {
                                        productImages.append(imageUrl as URL)
                                    }
                                }
                            }
                        }
                    }
            
                    cell.setImageElements(productImages)
                    
                    if let brandName = product.brand?.name
                    {
                        cell.brandLabel.text = brandName.uppercased()
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
                                cell.largePriceLabel.attributedText = NSAttributedString.priceString(withSalePrice: currentPrice, size: 17.0)
                                
                                cell.smallPriceLabel.attributedText = NSAttributedString.priceString(withRetailPrice: retailPrice, size: 12.0, strikethrough: true)
                            }
                            else
                            {
                                cell.largePriceLabel.attributedText = NSAttributedString.priceString(withRetailPrice: currentPrice, size: 17.0, strikethrough: false)
                            }
                        }
                        else
                        {
                            cell.largePriceLabel.attributedText = NSAttributedString.priceString(withRetailPrice: currentPrice, size: 17.0, strikethrough: false)
                        }
                    }
                    
                    cell.ctaButton.setAttributedTitle(NSAttributedString(string: "View Online".uppercased(), attributes: FontAttributes.filledButtonAttributes), for: .highlighted)
                                        
                    cell.ctaButton.addTarget(self, action: #selector(buy), for: .touchUpInside)

                    cell.ctaButton.setBackgroundColor(Color.NeonBlueColor, forState: UIControlState())
                    cell.ctaButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .highlighted)
    
                    cell.ctaButton.adjustsImageWhenHighlighted = false
                    
                    cell.selectionStyle = .none
                    
                    return cell
                    
                case .variant:
                    
                    if let variant: VariantType = VariantType(rawValue: (indexPath as NSIndexPath).row)
                    {
                        switch variant {
                        case .style:
                            
                            let cell: StyleCell = tableView.dequeueReusableCell(withIdentifier: "StyleCell") as! StyleCell
                            
                            cell.styleLabel.text = ""
                            
                            if let variantName = selectedVariant?.color
                            {
                                cell.styleLabel.text = variantName.capitalized
                            }
                            
                            // Should set color swatches here
                            
                            cell.selectionStyle = .none
                            
                            return cell
                            
                        case .size:
                            
                            let cell: SizeCell = tableView.dequeueReusableCell(withIdentifier: "SizeCell") as! SizeCell
                            
                            cell.sizeLabel.text = ""
                            
                            if let sizeName = selectedSize?.sizeName
                            {
                                cell.sizeLabel.text = sizeName
                            }
                            
                            cell.selectionStyle = .none
                            
                            return cell
                            
                            
                        case .moreDetails:
                            
                            let cell: MoreDetailsCell = tableView.dequeueReusableCell(withIdentifier: "MoreDetailsCell") as! MoreDetailsCell
                            
                            cell.moreDetailsLabel.attributedText = NSAttributedString(string: "View More Details".uppercased(), attributes: [NSForegroundColorAttributeName:Color.GrayColor,
                                NSFontAttributeName:Font.PrimaryFontSemiBold(size: 14.0),
                                NSKernAttributeName:1.5])
                            
                            return cell
                            
                        default:
                            log.debug("cellForRowAtIndexPath Error")
                            
                        }
                    }
                    
                default:
                    return UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
                }
            }
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
    }
    
    func highlightCTAButton(_ sender: UIButton)
    {
        sender.backgroundColor = Color.NeonBlueColor
        sender.titleLabel?.textColor = Color.white
    }
    
    func unhighlightCTAButton(_ sender: UIButton)
    {
        sender.backgroundColor = Color.NeonBlueHighlightedColor
        sender.titleLabel?.textColor = Color.white
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let tableSection: TableSection = TableSection(rawValue: (indexPath as NSIndexPath).section)
        {
           if tableSection == TableSection.productHeader
           {
                if cell is ProductHeaderCell
                {
                    cell.layoutIfNeeded()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if let headerView: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView
        {
            headerView.backgroundColor = Color.BackgroundGrayColor
        }
    }
    
    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let tableSection: TableSection = TableSection(rawValue: (indexPath as NSIndexPath).section)
        {
            switch tableSection {
            case .variant:
                
                if let variant = VariantType(rawValue: (indexPath as NSIndexPath).row)
                {
                    if variant == .style
                    {
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
                    else if variant == .size
                    {
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
                    else if variant == .moreDetails
                    {
                        // Present More Details View Controller
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        
                        if let moreDetailsVc = storyboard.instantiateViewController(withIdentifier: "MoreDetailsViewController") as? MoreDetailsViewController
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
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let tableSection: TableSection = TableSection(rawValue: (indexPath as NSIndexPath).section)
        {
            switch tableSection {
            case .productHeader:
//                return 398.0
                return UITableViewAutomaticDimension
                
            case .variant:
                return 48.0
                
            default:
                return 44.0
            }
        }
        
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == TableSection.productHeader.rawValue
        {
            return 451.0
        }
        else
        {
            return 48.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection {
            case .productHeader:
                return 8.0
                
            case .variant:
                return 4.0
                
            default:
                return 4.0
            }
        }
        
        return 4.0

    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if let tableSection: TableSection = TableSection(rawValue: section)
        {
            switch tableSection {
            case .productHeader:
                return 4.0
                
            case .variant:
                return 4.0
            
            default:
                return 8.0
            }
        }
        
        return 8.0
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == TableSection.variant.rawValue
        {
            if let cell: UITableViewCell = tableView.cellForRow(at: indexPath)
            {
                UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: { () -> Void in
                    
                    cell.backgroundColor = Color.HighlightedGrayColor
                    
                    if let styleCell = cell as? StyleCell
                    {
                        styleCell.colorSwatchView.alpha = 0.5
                    }
                    
                    }, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        if let cell: UITableViewCell = tableView.cellForRow(at: indexPath)
        {
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.white
                
                if let styleCell = cell as? StyleCell
                {
                    styleCell.colorSwatchView.alpha = 1.0
                }
                
                }, completion: nil)
        }
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
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
}
