//
//  SearchViewController.swift
//  Layers
//
//  Created by David Hodge on 6/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import FBSDKCoreKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var tableView: UITableView!
//    
//    @IBOutlet weak var searchTextField: UITextField!
//
//    @IBOutlet weak var cancelButton: UIButton!
//    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
//    @IBOutlet weak var searchNavButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults: Array<AnyObject>?
    
    var categories: Array<CategoryResponse>?
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    var keyboardNotificationObserver: AnyObject?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem.title = "Search".uppercaseString
        tabBarItem.image = UIImage(named: "search")
        tabBarItem.selectedImage = UIImage(named: "search-filled")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = Color.clearColor()
        
        searchBar.delegate = self

        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Color.BackgroundGrayColor
        tableView.separatorColor = Color.clearColor()
        
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-20, 0, 0, 0)

        spinner.color = Color.grayColor()
        spinner.hidesWhenStopped = true
        spinner.hidden = true
        view.addSubview(spinner)
        
        prepareToHandleKeyboard()

        fetchCategories()
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
    
    // MARK: Categories
    func fetchCategories()
    {
        spinner.startAnimating()
        spinner.hidden = false
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        FilterManager.defaultManager.fetchOriginalCategories({ (success, response) -> Void in
         
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.spinner.stopAnimating()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                })
            
            if success
            {
                if let categories = response as? Array<CategoryResponse>
                {
                    var parentCategories = Array<CategoryResponse>()
                    
                    // Parent Categories have a parentId of 1
                    parentCategories = categories.filter({ $0.parentId == 1})
                    
                    self.categories = parentCategories
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                      
                        self.tableView.reloadData()
                    })
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let alert = UIAlertController(title: "We're having trouble fetching categories right now.", message: nil, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        })
    }
    
    func shouldShowCategories() -> Bool
    {
        if searchBar.text?.characters.count > 0
        {
            return false
        }
        
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
            // Don't load results when the query string is 2 characters or less. This is not accurate enough.
        else if searchText.characters.count < 3
        {
            self.searchResults = nil
            
            self.tableView.reloadData()
        }
        else
        {
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
//            var tabBarHeight: CGFloat = 0
//            
//            if let tabBar = tabBarController?.tabBar
//            {
//                tabBarHeight = tabBar.bounds.size.height
//            }
            
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
            let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell")!
            
            cell.accessoryType = .DisclosureIndicator
            
            cell.textLabel?.textAlignment = .Left
            
            cell.textLabel?.textColor = Color.DarkTextColor
            
            cell.textLabel?.font = Font.OxygenRegular(size: 14.0)

            cell.selectionStyle = .Default
            
            if let searchResults = searchResults
            {
                if let brand = searchResults[safe: indexPath.row] as? BrandResponse
                {
                    if let brandName = brand.brandName
                    {
                        cell.textLabel?.text = brandName
                    }
                }
                else if let category = searchResults[safe: indexPath.row] as? CategoryResponse
                {
                    if let categoryName = category.categoryName
                    {
                        cell.textLabel?.text = categoryName
                    }
                }
                else if let product = searchResults[safe: indexPath.row] as? SimpleProductResponse
                {
                    if let brandName = product.brand?.brandName, let productName = product.productName
                    {
                        // Avoid repeating the brand twice, if the brand name is contained in both the product name and brand name
                        if productName.lowercaseString.rangeOfString(brandName.lowercaseString) == nil
                        {
                            cell.textLabel?.text = "\(brandName) \(productName)"
                        }
                        else
                        {
                            cell.textLabel?.text = "\(productName)"
                        }
                    }
                }
            }
            
            return cell
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

                cell.textLabel?.textColor = Color.DarkNavyColor
                
                if let categories = categories
                {
                    if let category = categories[safe: indexPath.row - 1]
                    {
                        if let categoryTitle = category.categoryName
                        {
                            cell.textLabel!.text = categoryTitle
                        }
                    }
                }
            }

            return cell
        }
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
                        
                        if let categoryName = category?.categoryName, categoryId = category?.categoryId
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
            if results[indexPath.row] is SimpleProductResponse
            {
                if let searchResults = searchResults,
                    let product = searchResults[indexPath.row] as? SimpleProductResponse
                {
                    if let productId = product.productId
                    {
                        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        
                        if let productVc = storyboard.instantiateViewControllerWithIdentifier("ProductViewController") as? ProductViewController
                        {
                            productVc.productIdentifier = productId
                            
                            navigationController?.pushViewController(productVc, animated: true)
                            
                            if let productName = product.productName
                            {
                                FBSDKAppEvents.logEvent("Search Product Selecttions", parameters: ["Product Name":productName, "Product ID":productId])
                            }
                        }
                    }
                }
            }
            else if results[indexPath.row] is BrandResponse
            {
                performSegueWithIdentifier("ShowSearchProductCollectionViewController", sender: ["indexPath": indexPath, "filterTypeValue": FilterType.Brand.rawValue])
            }
            else if results[indexPath.row] is CategoryResponse
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
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! ProductCell
        
        return cell
    }
    
    // MARK: CollectionView Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let searchResults = searchResults,
            let product = searchResults[indexPath.row] as? SimpleProductResponse
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
                                
                                if let brand = searchResults[indexPath.row] as? BrandResponse
                                {
                                    destinationVc.selectedItem = brand
                                    
                                    if let brandName = brand.brandName,
                                    let brandId = brand.brandId
                                    {
                                        FBSDKAppEvents.logEvent("Search Brand Selections", parameters: ["Brand Name":brandName, "Brand ID":brandId])
                                    }
                                }
                            }
                            else if filterType == FilterType.Category
                            {
                                destinationVc.filterType = filterType
                                
                                if let category = searchResults[indexPath.row] as? CategoryResponse
                                {
                                    destinationVc.selectedItem = category
                                    
                                    if let categoryName = category.categoryName,
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
            
            let constantModification = CGRectGetHeight(bounds) - keyboardFrameInViewCoordiantes.origin.y
            
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