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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var navBarImageView: UIImageView!
    
    var searchResults: Array<AnyObject>?
    
    var categories: Array<Category>?
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var keyboardNotificationObserver: AnyObject?
    
    var searchTimer: Timer?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem.title = "Search"
        tabBarItem.image = UIImage(named: "search-glass")
        tabBarItem.selectedImage = UIImage(named: "search-glass-filled")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navBarImageView.image = UIButton.imageFromColor(Color.PrimaryAppColor)
        
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = Color.clear
        
        searchBar.autocapitalizationType = .none
        
        searchBar.delegate = self
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        
        let customLayout = UICollectionViewFlowLayout()
        customLayout.scrollDirection = .vertical
        customLayout.minimumLineSpacing = 8.0
        customLayout.minimumInteritemSpacing = 8.0
        customLayout.sectionInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        collectionView.collectionViewLayout = customLayout
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Color.BackgroundGrayColor
        tableView.separatorColor = Color.clear
        
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-20, 0, 0, 0)
        
        spinner.color = Color.gray
        spinner.hidesWhenStopped = true
        spinner.isHidden = true
        view.addSubview(spinner)
        
        prepareToHandleKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        spinner.center = tableView.center
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)

        view.endEditing(true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func shouldShowCategories() -> Bool
    {
        if searchBar.text?.characters.count > 0
        {
            self.tableView.isHidden = false
            self.collectionView.isHidden = true
            
            return false
        }
        
        self.tableView.isHidden = true
        self.collectionView.isHidden = false
        
        return true
    }
    
    // MARK: Search Bar Delegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if shouldShowCategories()
        {
            self.tableView.reloadData()
        }
        else
        {
            // Use timer to handle search queries sequentially as the user is typing. If the search query has changed and the previous query has not yet returned, the previous query is invalidated
            if let searchTimer = searchTimer
            {
                if searchTimer.isValid
                {
                    searchTimer.invalidate()
                }
            }
            
            searchTimer = nil
            
            searchTimer = Timer.after(0.3, { () -> Void in
                
                LRSessionManager.sharedManager.search(searchText, completionHandler: { (success, error, response) -> Void in
                    
                    if success
                    {
                        if let results = response as? Array<AnyObject>
                        {
                            self.searchResults = results
                            
                            DispatchQueue.main.async {
                                
                                self.tableView.reloadData()
                            }
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
            tableView.setContentOffset(CGPoint.zero, animated: true)
        }
        
        FBSDKAppEvents.logEvent("Search Queries", parameters: ["Query String":searchText])
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        FBSDKAppEvents.logEvent("Search Bar Taps")
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(false, animated: true)

        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    // MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if shouldShowCategories()
        {
            tableView.contentInset = UIEdgeInsets(top: 48, left: tableView.contentInset.left, bottom: 48, right: tableView.contentInset.right)
            
            tableView.backgroundColor = Color.white
            
            tableView.setContentOffset(CGPoint(x: 0, y: -48), animated: false)
        }
        else
        {
            tableView.contentInset = UIEdgeInsets(top: 0, left: tableView.contentInset.left, bottom: 0, right: tableView.contentInset.right)
            
            tableView.backgroundColor = Color.BackgroundGrayColor
            
            tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
        
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchResults?.count > 0 && !shouldShowCategories()
        {
            if let cell: SearchCell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as? SearchCell
            {
                cell.resultImageView.image = nil
                cell.titleLabel.text = nil
                
                cell.accessoryType = .disclosureIndicator
                
                cell.titleLabel?.textColor = Color.DarkTextColor
                
                cell.selectionStyle = .default
                
                var resultText: String?
                
                if let searchResults = searchResults
                {
                    if let brand = searchResults[safe: (indexPath as NSIndexPath).row] as? Brand
                    {
                        if let brandName = brand.name
                        {
                            resultText = brandName
                        }
                    }
                    else if let category = searchResults[safe: (indexPath as NSIndexPath).row] as? Category
                    {
                        if let categoryName = category.name
                        {
                            resultText = categoryName
                        }
                    }
                    else if let product = searchResults[safe: (indexPath as NSIndexPath).row] as? SimpleProduct
                    {
                        if let productName = product.brandedName
                        {
                            resultText = productName
                        }
                        
                        if let imageUrl = product.image?.url
                        {
                            cell.resultImageView.sd_setImage(with: imageUrl)
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
                                let regex = try NSRegularExpression(pattern: "\(word)", options: .caseInsensitive)
                                
                                let range = NSMakeRange(0, resultText.characters.count)
                                
                                regex.enumerateMatches(in: resultText, options: .reportCompletion, range: range, using: { (result, flags, stop) -> Void in
                                    
                                    if let substringRange = result?.rangeAt(0)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
            
            cell.accessoryType = .none
            
            cell.selectionStyle = .none

            cell.textLabel?.textAlignment = .center
            
            if (indexPath as NSIndexPath).row == 0
            {
                // Heading Cell
                cell.textLabel?.text = "FEATURED CATEGORIES"
                
                cell.textLabel?.textColor = Color.gray
                
                cell.textLabel?.font = Font.OxygenBold(size: 14.0)
            }
            else
            {
                cell.textLabel?.font = Font.OxygenRegular(size: 16.0)

                cell.textLabel?.textColor = Color.PrimaryAppColor
                
                if let categories = categories
                {
                    if let category = categories[safe: (indexPath as NSIndexPath).row - 1]
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
        
        return UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
    }
    
    // MARK: Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if shouldShowCategories()
        {
            if let categories = categories
            {
                // Header Cell has no action
                if (indexPath as NSIndexPath).row != 0
                {
                    let category = categories[safe: (indexPath as NSIndexPath).row - 1]
                    
                    let searchStoryboard = UIStoryboard(name: "Search", bundle: Bundle.main)
                    
                    if let searchProductCollectionVc = searchStoryboard.instantiateViewController(withIdentifier: "SearchProductCollectionViewController") as? SearchProductCollectionViewController
                    {
                        searchProductCollectionVc.filterType = FilterType.category
                        
                        searchProductCollectionVc.selectedItem = category
                        
                        navigationController?.pushViewController(searchProductCollectionVc, animated: true)
                        
                        if let categoryName = category?.name, let categoryId = category?.categoryId
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
            if results[(indexPath as NSIndexPath).row] is SimpleProduct
            {
                if let searchResults = searchResults,
                    let product = searchResults[(indexPath as NSIndexPath).row] as? SimpleProduct
                {
                    if let productId = product.productId
                    {
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        
                        if let productVc = storyboard.instantiateViewController(withIdentifier: "ProductViewController") as? ProductViewController
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
            else if results[(indexPath as NSIndexPath).row] is Brand
            {
                performSegue(withIdentifier: "ShowSearchProductCollectionViewController", sender: ["indexPath": indexPath, "filterTypeValue": FilterType.brand.rawValue])
            }
            else if results[(indexPath as NSIndexPath).row] is Category
            {
                performSegue(withIdentifier: "ShowSearchProductCollectionViewController", sender: ["indexPath": indexPath, "filterTypeValue": FilterType.category.rawValue])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if shouldShowCategories()
        {
            if (indexPath as NSIndexPath).row == 0
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    // MARK: CollectionView Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 11
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath)
        
        cell.backgroundColor = Color.white
        
        return cell
    }
    
    // MARK: CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let searchResults = searchResults,
            let product = searchResults[(indexPath as NSIndexPath).row] as? Product
        {
            if let productId = product.productId
            {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                
                if let productVc = storyboard.instantiateViewController(withIdentifier: "ProductViewController") as? ProductViewController
                {
                    productVc.productIdentifier = productId
                }
            }
        }
    }
    
    // MARK: RFQuiltLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
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
            
            let remainder = (indexPath as NSIndexPath).row % segmentSize
            
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 8.0
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowSearchProductCollectionViewController"
        {
            if let destinationVc = segue.destination as? SearchProductCollectionViewController,
            let senderDict = sender as? Dictionary<String,AnyObject>,
                let searchResults = searchResults
            {
                if let indexPath = senderDict["indexPath"]
                {
                    if let filterTypeValue = senderDict["filterTypeValue"] as? Int
                    {
                        if let filterType = FilterType(rawValue: filterTypeValue)
                        {
                            if filterType == FilterType.brand
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
                            else if filterType == FilterType.category
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
        keyboardNotificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: OperationQueue.main) { [weak self] (notification) -> Void in
            
            let frame : CGRect = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            guard let keyboardFrameInViewCoordiantes = self?.view.convert(frame, from: nil), let bounds = self?.view.bounds else { return; }
            
            var constantModification = bounds.height - keyboardFrameInViewCoordiantes.origin.y
            
            if constantModification < 0
            {
                constantModification = 0
            }
            
            let duration:TimeInterval = ((notification as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = (notification as NSNotification).userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            
            UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: { [weak self] () -> Void in
                
                self?.tableViewBottomConstraint.constant = constantModification
                
                self?.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
}
