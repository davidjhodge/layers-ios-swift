//
//  SearchViewController.swift
//  Layers
//
//  Created by David Hodge on 6/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
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
        
        searchBar.tintColor = Color.clearColor()
        searchBar.barTintColor = Color.clearColor()
        searchBar.backgroundImage = UIImage()
        
        searchBar.delegate = self
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Color.BackgroundGrayColor
        
        spinner.color = Color.grayColor()
        spinner.hidesWhenStopped = true
        spinner.hidden = true
        
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
        FilterManager.defaultManager.fetchOriginalCategories({ (success, response) -> Void in
         
            if success
            {
                if let categories = response as? Array<CategoryResponse>
                {
                    var parentCategories = Array<CategoryResponse>()
                    
                    // Parent Categories have a key of 2
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
        
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
        
        tableView.reloadData()
        
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text.characters.count == 0
        {
            tableView.setContentOffset(CGPointZero, animated: true)
        }
        
        return true
    }
    
    // MARK: Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if shouldShowCategories()
        {
            var tabBarHeight: CGFloat = 0
            
            if let tabBar = tabBarController?.tabBar
            {
                tabBarHeight = tabBar.bounds.size.height
            }
            
            tableView.contentInset = UIEdgeInsets(top: 24, left: tableView.contentInset.left, bottom: 24, right: tableView.contentInset.right)
        }
        else
        {
            tableView.contentInset = UIEdgeInsets(top: 0, left: tableView.contentInset.left, bottom: 0, right: tableView.contentInset.right)
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
                return categories.count
            }
        }
        

        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if searchResults?.count > 0 && !shouldShowCategories()
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell")!
            
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
            
            cell.accessoryType = .DisclosureIndicator
            
            if let categories = categories
            {
                if let category = categories[safe: indexPath.row]
                {
                    if let categoryTitle = category.categoryName
                    {
                        cell.textLabel!.text = categoryTitle
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
                let category = categories[safe: indexPath.row]
                
                let searchStoryboard = UIStoryboard(name: "Search", bundle: NSBundle.mainBundle())
                
                if let searchProductCollectionVc = searchStoryboard.instantiateViewControllerWithIdentifier("SearchProductCollectionViewController") as? SearchProductCollectionViewController
                {
                    searchProductCollectionVc.filterType = FilterType.Category
                        
                    searchProductCollectionVc.selectedItem = category
                    
                    navigationController?.pushViewController(searchProductCollectionVc, animated: true)
                }
            }
        }
        else if let results = searchResults
        {
            if results[indexPath.row] is SimpleProductResponse
            {
                performSegueWithIdentifier("ShowProductViewController", sender: indexPath)
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
        return 48.0
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
        
        performSegueWithIdentifier("ShowProductViewController", sender: indexPath)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowProductViewController"
        {
            if let destinationVc = segue.destinationViewController as? ProductViewController,
                let indexPath = sender as? NSIndexPath,
                let searchResults = searchResults,
                let product = searchResults[indexPath.row] as? SimpleProductResponse
            {
                
                if let productId = product.productId
                {
                    destinationVc.productIdentifier = productId
                }
            }
        }
        else if segue.identifier == "ShowSearchProductCollectionViewController"
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
                                }
                            }
                            else if filterType == FilterType.Category
                            {
                                destinationVc.filterType = filterType
                                
                                if let category = searchResults[indexPath.row] as? CategoryResponse
                                {
                                    destinationVc.selectedItem = category
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