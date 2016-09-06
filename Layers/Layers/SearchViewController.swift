//
//  SearchViewController.swift
//  Layers
//
//  Created by David Hodge on 6/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import SwiftyTimer

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var navBarImageView: UIImageView!
    
    var searchResults: Array<AnyObject>?
    
    var categories: Array<Category>?
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    var keyboardNotificationObserver: AnyObject?
    
    var searchTimer: NSTimer?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem.title = "Search"
        tabBarItem.image = UIImage(named: "search")
        tabBarItem.selectedImage = UIImage(named: "search-filled")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navBarImageView.image = UIButton.imageFromColor(Color.PrimaryAppColor)
        
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = Color.clearColor()
        
    
        
        searchBar.delegate = self
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        
        let customLayout = UICollectionViewFlowLayout()
        customLayout.scrollDirection = .Vertical
        customLayout.minimumLineSpacing = 8.0
        customLayout.minimumInteritemSpacing = 8.0
        customLayout.sectionInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        collectionView.collectionViewLayout = customLayout
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Color.BackgroundGrayColor
        tableView.separatorColor = Color.clearColor()
        
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-20, 0, 0, 0)
        
        spinner.color = Color.grayColor()
        spinner.hidesWhenStopped = true
        spinner.hidden = true
        view.addSubview(spinner)
        
        prepareToHandleKeyboard()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        spinner.center = tableView.center
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)

        view.endEditing(true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func shouldShowCategories() -> Bool
    {
        if searchBar.text?.characters.count > 0
        {
            self.tableView.hidden = false
            self.collectionView.hidden = true
            
            return false
        }
        
        self.tableView.hidden = true
        self.collectionView.hidden = false
        
        return true
    }
    
    // MARK: Search Bar Delegate
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
        
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if shouldShowCategories()
        {
            self.tableView.reloadData()
        }
        else
        {
            // Use timer to handle search queries sequentially as the user is typing. If the search query has changed and the previous query has not yet returned, the previous query is invalidated
            if let searchTimer = searchTimer
            {
                if searchTimer.valid
                {
                    searchTimer.invalidate()
                }
            }
            
            searchTimer = nil
            
            searchTimer = NSTimer.after(0.3, { () -> Void in
                
                LRSessionManager.sharedManager.search(searchText, completionHandler: { (success, error, response) -> Void in
                    
                    if success
                    {
                        if let results = response as? Array<AnyObject>
                        {
                            self.searchResults = results
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                self.tableView.reloadData()
                            })
                        }
                    }
                    else
                    {
                        log.error("Search Error.")
                    }
                })
            })
        }
        
        if searchText.characters.count == 0
        {
            tableView.setContentOffset(CGPointZero, animated: true)
        }
        
        FBSDKAppEvents.logEvent("Search Queries", parameters: ["Query String":searchText])
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        FBSDKAppEvents.logEvent("Search Bar Taps")
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(false, animated: true)

        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    // MARK: Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if shouldShowCategories()
        {
            tableView.contentInset = UIEdgeInsets(top: 48, left: tableView.contentInset.left, bottom: 48, right: tableView.contentInset.right)
            
            tableView.backgroundColor = Color.whiteColor()
            
            tableView.setContentOffset(CGPointMake(0, -48), animated: false)
        }
        else
        {
            tableView.contentInset = UIEdgeInsets(top: 0, left: tableView.contentInset.left, bottom: 0, right: tableView.contentInset.right)
            
            tableView.backgroundColor = Color.BackgroundGrayColor
            
            tableView.setContentOffset(CGPointMake(0, 0), animated: false)
        }
        
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if !shouldShowCategories()
        {
            if let results = searchResults
            {
                return results.count
            }
        }
        else
        {
            if let categories = categories
            {
                return categories.count + 1
            }
        }
        

        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if searchResults?.count > 0 && !shouldShowCategories()
        {
            if let cell: SearchCell = tableView.dequeueReusableCellWithIdentifier("SearchCell") as? SearchCell
            {
                cell.resultImageView.image = nil
                cell.titleLabel.text = nil
                
                cell.accessoryType = .DisclosureIndicator
                
                cell.titleLabel?.textColor = Color.DarkTextColor
                
                cell.selectionStyle = .Default
                
                var resultText: String?
                
                if let searchResults = searchResults
                {
                    if let brand = searchResults[safe: indexPath.row] as? Brand
                    {
                        if let brandName = brand.name
                        {
                            resultText = brandName
                        }
                    }
                    else if let category = searchResults[safe: indexPath.row] as? Category
                    {
                        if let categoryName = category.name
                        {
                            resultText = categoryName
                        }
                    }
                    else if let product = searchResults[safe: indexPath.row] as? SimpleProduct
                    {
                        if let productName = product.brandedName
                        {
                            resultText = productName
                        }
                        
                        if let imageUrl = product.image?.url
                        {
                            cell.resultImageView.sd_setImageWithURL(imageUrl)
                        }
                    }
                }
                
                if let resultText = resultText
                {
                    let attributedString = NSMutableAttributedString(string: resultText, attributes: FontAttributes.darkBodyTextAttributes)
                    
                    // Bolden query match
                    if let searchQuery = searchBar.text
                    {
                        let words = searchQuery.characters.split{ $0 == " " }.map(String.init)
                        
                        for word in words
                        {
                            do {
                                let regex = try NSRegularExpression(pattern: "\(word)", options: .CaseInsensitive)
                                
                                let range = NSMakeRange(0, resultText.characters.count)
                                
                                regex.enumerateMatchesInString(resultText, options: .ReportCompletion, range: range, usingBlock: { (result, flags, stop) -> Void in
                                    
                                    if let substringRange = result?.rangeAtIndex(0)
                                    {
                                        attributedString.addAttribute(NSFontAttributeName, value: Font.PrimaryFontSemiBold(size: 12.0), range: substringRange)
                                    }
                                })
                                
                            } catch
                            {
                                // Substring not found
                            }
                        }
                    }
                    
                    cell.titleLabel?.attributedText = attributedString
                }
                
                return cell
            }
        }
        else
        {
            // Show Categories
            let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell")!
            
            cell.accessoryType = .None
            
            cell.selectionStyle = .None

            cell.textLabel?.textAlignment = .Center
            
            if indexPath.row == 0
            {
                // Heading Cell
                cell.textLabel?.text = "FEATURED CATEGORIES"
                
                cell.textLabel?.textColor = Color.grayColor()
                
                cell.textLabel?.font = Font.OxygenBold(size: 14.0)
            }
            else
            {
                cell.textLabel?.font = Font.OxygenRegular(size: 16.0)

                cell.textLabel?.textColor = Color.PrimaryAppColor
                
                if let categories = categories
                {
                    if let category = categories[safe: indexPath.row - 1]
                    {
                        if let categoryTitle = category.name
                        {
                            cell.textLabel!.text = categoryTitle
                        }
                    }
                }
            }

            return cell
        }
        
        return UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
    }
    
    // MARK: Table View Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if shouldShowCategories()
        {
            if let categories = categories
            {
                // Header Cell has no action
                if indexPath.row != 0
                {
                    let category = categories[safe: indexPath.row - 1]
                    
                    let searchStoryboard = UIStoryboard(name: "Search", bundle: NSBundle.mainBundle())
                    
                    if let searchProductCollectionVc = searchStoryboard.instantiateViewControllerWithIdentifier("SearchProductCollectionViewController") as? SearchProductCollectionViewController
                    {
                        searchProductCollectionVc.filterType = FilterType.Category
                        
                        searchProductCollectionVc.selectedItem = category
                        
                        navigationController?.pushViewController(searchProductCollectionVc, animated: true)
                        
                        if let categoryName = category?.name, categoryId = category?.categoryId
                        {
                            FBSDKAppEvents.logEvent("Search Categories Selected", parameters: ["Category Name":categoryName, "Category ID":categoryId
                                ])
                        }
                    }
                }
            }
        }
        else if let results = searchResults
        {
            if results[indexPath.row] is SimpleProduct
            {
                if let searchResults = searchResults,
                    let product = searchResults[indexPath.row] as? SimpleProduct
                {
                    if let productId = product.productId
                    {
                        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        
                        if let productVc = storyboard.instantiateViewControllerWithIdentifier("ProductViewController") as? ProductViewController
                        {
                            productVc.productIdentifier = productId
                            
                            navigationController?.pushViewController(productVc, animated: true)
                            
                            if let productName = product.brandedName
                            {
                                FBSDKAppEvents.logEvent("Search Product Selecttions", parameters: ["Product Name":productName, "Product ID":productId])
                            }
                        }
                    }
                }
            }
            else if results[indexPath.row] is Brand
            {
                performSegueWithIdentifier("ShowSearchProductCollectionViewController", sender: ["indexPath": indexPath, "filterTypeValue": FilterType.Brand.rawValue])
            }
            else if results[indexPath.row] is Category
            {
                performSegueWithIdentifier("ShowSearchProductCollectionViewController", sender: ["indexPath": indexPath, "filterTypeValue": FilterType.Category.rawValue])
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if shouldShowCategories()
        {
            if indexPath.row == 0
            {
                return 64.0
            }
            else
            {
                return 40.0
            }
        }
        else
        {
            return 48.0
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    // MARK: CollectionView Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 11
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCell", forIndexPath: indexPath)
        
        cell.backgroundColor = Color.whiteColor()
        
        return cell
    }
    
    // MARK: CollectionView Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let searchResults = searchResults,
            let product = searchResults[indexPath.row] as? Product
        {
            if let productId = product.productId
            {
                let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                
                if let productVc = storyboard.instantiateViewControllerWithIdentifier("ProductViewController") as? ProductViewController
                {
                    productVc.productIdentifier = productId
                }
            }
        }
    }
    
    // MARK: RFQuiltLayout

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        {
            // Define Heights
            let smallCellHeight: CGFloat = 176.0
            
            let mediumCellHeight: CGFloat = 228.0
            
            let largeCellHeight: CGFloat = 228.0
            
            // Define Widths
            
            let smallCellWidth = ((view.bounds.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing) * 0.5)
            
            let mediumCellWidth: CGFloat = smallCellWidth
            
            let largeCellWidth = view.bounds.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
            
            let segmentSize = 6
            
            let remainder = indexPath.row % segmentSize
            
            if remainder == 2 || remainder == 5
            {
                // Large Cell
                return CGSize(width: largeCellWidth, height: largeCellHeight)
            }
            else if remainder == 0 || remainder == 1
            {
                // Medium Cell
                return CGSize(width: mediumCellWidth, height: mediumCellHeight)
            }
            else if remainder == 3 || remainder == 4
            {
                // Small Cell
                return CGSize(width: smallCellWidth, height: smallCellHeight)
            }
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        
        return 8.0
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowSearchProductCollectionViewController"
        {
            if let destinationVc = segue.destinationViewController as? SearchProductCollectionViewController,
            let senderDict = sender as? Dictionary<String,AnyObject>,
                let searchResults = searchResults
            {
                if let indexPath = senderDict["indexPath"]
                {
                    if let filterTypeValue = senderDict["filterTypeValue"] as? Int
                    {
                        if let filterType = FilterType(rawValue: filterTypeValue)
                        {
                            if filterType == FilterType.Brand
                            {
                                destinationVc.filterType = filterType
                                
                                if let brand = searchResults[indexPath.row] as? Brand
                                {
                                    destinationVc.selectedItem = brand
                                    
                                    if let brandName = brand.name,
                                    let brandId = brand.brandId
                                    {
                                        FBSDKAppEvents.logEvent("Search Brand Selections", parameters: ["Brand Name":brandName, "Brand ID":brandId])
                                    }
                                }
                            }
                            else if filterType == FilterType.Category
                            {
                                destinationVc.filterType = filterType
                                
                                if let category = searchResults[indexPath.row] as? Category
                                {
                                    destinationVc.selectedItem = category
                                    
                                    if let categoryName = category.name,
                                    let categoryId = category.categoryId
                                    {
                                        FBSDKAppEvents.logEvent("Search Category Selections", parameters: ["Category Name":categoryName, "Category ID":categoryId])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Handle Keyboard
    func prepareToHandleKeyboard()
    {
        keyboardNotificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillChangeFrameNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            
            let frame : CGRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            
            guard let keyboardFrameInViewCoordiantes = self?.view.convertRect(frame, fromView: nil), bounds = self?.view.bounds else { return; }
            
            var constantModification = CGRectGetHeight(bounds) - keyboardFrameInViewCoordiantes.origin.y
            
            if constantModification < 0
            {
                constantModification = 0
            }
            
            let duration:NSTimeInterval = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            
            UIView.animateWithDuration(duration, delay: 0.0, options: animationCurve, animations: { [weak self] () -> Void in
                
                self?.tableViewBottomConstraint.constant = constantModification
                
                self?.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}