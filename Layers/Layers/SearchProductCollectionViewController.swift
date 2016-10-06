//
//  SearchProductCollectionViewController.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import NHAlignmentFlowLayout
import SDWebImage

class SearchProductCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FilterDelegate
{
    fileprivate let kProductCellIdentfier = "ProductCell"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewBottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emptyStateView: EmptyStateView!

    @IBOutlet weak var editFilterButton: UIButton!
    
    var filterType: FilterType?
    
    var selectedItem: AnyObject?
    
    var filterItem: AnyObject?
    
    var products: Array<Product>?
    
    var currentPage: Int?
    
    var hasMore: Bool = true
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change status bar style to .LightContent
        navigationController?.navigationBar.barStyle = .black
        
        // Update Filter with Selection
        var currentFilter = FilterManager.defaultManager.getCurrentFilter()
        
        currentFilter = Filter()

        if let selection = selectedItem
        {
            if let category = selection as? Category
            {
                filterItem = category
                
                if let categoryTitle = category.name
                {
                    title = categoryTitle.uppercased()
                }
                
                // Update Filter
                if let filterObject = FilterObjectConverter.filterObject(category)
                {
                    currentFilter.categories.selections = [filterObject]
                }
            }
            else if let brand = selection as? Brand
            {
                filterItem = brand
                
                if let brandName = brand.name
                {
                    title = brandName.uppercased()
                }
                
                // Update Filter
                if let filterObject = FilterObjectConverter.filterObject(brand)
                {
                    currentFilter.brands.selections = [filterObject]
                }
            }
        }
        
        FilterManager.defaultManager.setNewFilter(currentFilter)
        
        let filterButton = UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(filter))
        
        editFilterButton.setBackgroundColor(Color.NeonBlueColor, forState: UIControlState())
        editFilterButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .highlighted)

        editFilterButton.addTarget(self, action: #selector(filter), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = filterButton
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        // Flow Layout
        let customLayout = NHAlignmentFlowLayout()
        customLayout.scrollDirection = .vertical
        customLayout.alignment = .topLeftAligned
        customLayout.minimumLineSpacing = 8.0
        customLayout.minimumInteritemSpacing = 8.0
        customLayout.sectionInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        collectionView.collectionViewLayout = customLayout
        
        spinner.color = Color.gray
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        currentPage = 1
        
        reloadProducts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        spinner.center = collectionView.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selection = selectedItem
        {
            if let _ = selection as? Category
            {
                if let currentSelections = FilterManager.defaultManager.getCurrentFilter().categories.selections
                {
                    if currentSelections.count == 1
                    {
                        if let categoryFilter: FilterObject = currentSelections.first
                        {
                            title = categoryFilter.name?.uppercased()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Networking
    func reloadProducts()
    {
        // Get next page of results
        if let page = currentPage , page > 0
        {
            emptyStateView.isHidden = true
            collectionView.isHidden = false
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            if products == nil || products?.count == 0
            {
                spinner.startAnimating()
            }
            
            LRSessionManager.sharedManager.loadProductCollection(page, completionHandler: { (success, error, response) -> Void in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                if self.spinner.isAnimating
                {
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        self.spinner.stopAnimating()
                    })
                }
                
                if success
                {
                    if let newProducts: Array<Product> = response as? Array<Product>
                    {
                        self.currentPage = page + 1
                        
                        // If this is the first page of results
                        if page == 1
                        {
                            if newProducts.count > 0
                            {
                                // Update products and reload collection
                                self.products = newProducts

                                self.hardReloadCollectionView()
                            }
                            else
                            {
                                if FilterManager.defaultManager.getCurrentFilter().hasActiveFilters()
                                {
                                    // New filter yielded 0 products. Show Alert
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        
                                        self.emptyStateView.isHidden = false
                                        self.collectionView.isHidden = true

                                        log.debug("NO_RESULTS_FOR_FILTER".localized)

                                    })
                                }
                            }
                        }
                        else
                        {
                            if newProducts.count > 0
                            {
                                // If this is a response for page 2 or greater
                                self.products?.append(contentsOf: newProducts)
                                
                                // Update UI
                                DispatchQueue.main.async(execute: { () -> Void in
                                    
                                    let topOffset = self.collectionView.contentOffset.y
                                    
                                    //Insert new products
                                    CATransaction.begin()
                                    CATransaction.setDisableActions(true)
                                    
                                    self.collectionView.performBatchUpdates({ () -> Void in
                                        
                                        var indexPaths = Array<IndexPath>()
                                        
                                        // The first index to insert into
                                        if let productCount = self.products?.count
                                        {
                                            let index = productCount - newProducts.count
                                                                                        
                                            for i in index...index + newProducts.count - 1
                                            {
                                                indexPaths.append(IndexPath(row: i, section: 0))
                                            }
                                            
                                            self.collectionView.insertItems(at: indexPaths)
                                            
                                        }
                                        }, completion: { (finished) -> Void in
                                            
                                            // Set correct content offset
                                            self.collectionView.contentOffset = CGPoint(x: 0, y: topOffset)
                                            
                                            CATransaction.commit()
                                    })
                                })
                            }
                            else
                            {
                                // Remove loading cell
                                DispatchQueue.main.async(execute: { () -> Void in
                                    
                                    let topOffset = self.collectionView.contentOffset.y
                                    
                                    CATransaction.begin()
                                    CATransaction.setDisableActions(true)
                                    
                                    self.collectionView.performBatchUpdates({ () -> Void in
                                        
                                        }, completion: { (finished) -> Void in
                                            
                                            // Set correct content offset
                                            self.collectionView.contentOffset = CGPoint(x: 0, y: topOffset)
                                            CATransaction.commit()
                                    })
                                })
                            }
                        }
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
            let alert = UIAlertController(title: "Page not specified.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func hardReloadCollectionView()
    {
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.collectionView.reloadData()
            
            self.collectionView.setContentOffset(CGPoint.zero, animated: false)
        })
    }
    
    // MARK: Actions
    func filter()
    {
        FBSDKAppEvents.logEvent("Filter Buttons Taps")
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if let filterVc = mainStoryboard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController
        {
            filterVc.delegate = self
            
            let navController = UINavigationController(rootViewController: filterVc)
            
            present(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: Filter Delegate
    func didUpdateFilter()
    {
        // Reset current page to 1, because the Filter has changed, which yields a different set of results
        currentPage = 1
        
        reloadProducts()
    }
    
    // MARK: Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let items = products , items.count > 0
        {
            return items.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let items = products
        {
            let product: Product = items[(indexPath as NSIndexPath).row]
            
            let cell: ProductCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentfier, for: indexPath) as! ProductCell
            
            cell.brandLabel.text = ""
            cell.priceLabel.text = ""
            
            // If no color filters are activated, use the first variant. Else, use the first variant with a matching color.
            var variant: Variant?
            
            if let variants = product.variants
            {
                // Returns a variant that matches the color
                if let matchingVariant = Variant.variantMatchingFilterColorsInVariants(variants)
                {
                    variant = matchingVariant
                }
            }
            
            if variant == nil
            {
                if let firstVariant = product.variants?[safe: 0]
                {
                    variant = firstVariant
                }
            }
            
            //Set Image View with first image
            
            if let primaryImageResolutions = product.images?.primaryImageUrls
            {
                if let imageIndex = primaryImageResolutions.index(where: { $0.sizeName == "IPhone" })
                {
                    if let primaryImage: Image = primaryImageResolutions[safe: imageIndex]
                    {
                        if let imageUrl = primaryImage.url
                        {
                            cell.productImageView.sd_setImage(with: imageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                                
                                if image != nil && cacheType != .memory
                                {
                                    cell.productImageView.alpha = 0.0
                                    
                                    UIView.animate(withDuration: 0.3, animations: {
                                        cell.productImageView.alpha = 1.0
                                    })
                                }
                            })
                        }
                    }
                }
            }
            
            //Set Price
            var currentPrice: NSNumber?
            var retailPrice: NSNumber?
            
            if let currPrice = product.altPrice?.salePrice
            {
                currentPrice = currPrice
            }
            
            if let retail = product.price?.price
            {
                retailPrice = retail
            }
            
            if currentPrice != nil
            {
                cell.priceLabel.attributedText = NSAttributedString.priceString(withRetailPrice: retailPrice, salePrice: currentPrice)
            }
            else
            {
                if let retailPrice = retailPrice
                {
                    cell.priceLabel.attributedText = NSAttributedString.priceString(withRetailPrice: retailPrice, size: 14.0, strikethrough: false)
                }
            }
            
            if let brandName = product.brand?.name
            {
                cell.brandLabel.attributedText = NSAttributedString(string: brandName.uppercased(), attributes: FontAttributes.headerTextAttributes)
            }
            
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentfier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let products = products
        {
            // Insert next page of items as we near the end of the current list
            if (indexPath as NSIndexPath).row == products.count - 3
            {
                // Auto-increments page, so no <page> parameter is required
                reloadProducts()
            }
        }
    }
    
    // MARK: Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if let productVc = mainStoryboard.instantiateViewController(withIdentifier: "ProductViewController") as? ProductViewController
        {
            if let productCollection = products
            {
                if let product = productCollection[(indexPath as NSIndexPath).row] as Product?
                {
                    if let productId = product.productId
                    {
                        productVc.productIdentifier = productId
                        
                        navigationController?.pushViewController(productVc, animated: true)
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (indexPath as NSIndexPath).row == products?.count
        {
            // Size for Loading Cell
            return CGSize(width: collectionView.bounds.size.width - 16, height: 40.0)
        }
        else
        {
            // Size for Product Cell
            let flowLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            
            let width: CGFloat = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - 8) * 0.5
            
            return CGSize(width: width, height: 226.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItem(at: indexPath)
        {
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.HighlightedGrayColor
                
                if let productCell = cell as? ProductCell
                {
                    productCell.productImageView.alpha = 0.5
                }
                
                }, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        
        if let cell: UICollectionViewCell = collectionView.cellForItem(at: indexPath)
        {
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: { () -> Void in
                
                cell.backgroundColor = Color.white
                
                if let productCell = cell as? ProductCell
                {
                    productCell.productImageView.alpha = 1.0
                }
                
                }, completion: nil)
        }
    }
}
