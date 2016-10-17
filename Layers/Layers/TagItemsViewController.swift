//
//  TagItemsViewController.swift
//  Layers
//
//  Created by David Hodge on 10/15/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class TagItemsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CustomProductDelegate
{
    @IBOutlet weak var tableView: UITableView!
        
    @IBOutlet weak var searchBar: UISearchBar!
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    var searchResults: Array<SimpleProduct>?
    
    var searchTimer: Timer?
    
    var selectedProduct: SimpleProduct?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Tag an Item"
        
        // Change status bar style to .LightContent
        navigationController?.navigationBar.barStyle = .black
        
        tableView.tableFooterView = UIView()
        tableView.backgroundView?.backgroundColor = Color.BackgroundGrayColor
        tableView.separatorStyle = .none
        
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = Color.clear
        searchBar.tintColor = Color.PrimaryAppColor
        
        searchBar.autocapitalizationType = .none
        
        searchBar.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(showFinalShareScreen))
    }
    
    func searchGoogle()
    {
        let storyboard = UIStoryboard(name: "Upload", bundle: Bundle.main)
        
        if let findProductVc = storyboard.instantiateViewController(withIdentifier: "FindProductWebViewController") as? FindProductWebViewController
        {
            findProductVc.searchText = searchBar.text
            
            findProductVc.customProductDelegate = self
            
            navigationController?.pushViewController(findProductVc, animated: true)
        }
    }
    
    func showFinalShareScreen()
    {
        let storyboard = UIStoryboard(name: "Upload", bundle: Bundle.main)
        
        if let findProductVc = storyboard.instantiateViewController(withIdentifier: "SharePostViewController") as? SharePostViewController
        {
            if let selectedProductId = selectedProduct?.productId
            {
                findProductVc.productId = selectedProductId
                
                navigationController?.pushViewController(findProductVc, animated: true)
            }
        }
    }
    
    // MARK: Search Bar Delegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
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
            
            LRSessionManager.sharedManager.searchProducts(searchText, completionHandler: { (success, error, response) -> Void in
                
                if success
                {
                    if let results = response as? Array<SimpleProduct>
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
        
        if searchText.characters.count == 0
        {
            tableView.setContentOffset(CGPoint.zero, animated: true)
        }
        
        FBSDKAppEvents.logEvent("Tag Items Search Queries", parameters: ["Query String":searchText])
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
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
    
    // MARK: Custom Product Delegate
    func customProduct(_ image: UIImage, productUrl: URL) {
        
        let storyboard = UIStoryboard(name: "Upload", bundle: Bundle.main)
        
        if let sharePostVc = storyboard.instantiateViewController(withIdentifier: "SharePostViewController") as? SharePostViewController
        {
            sharePostVc.customProductImage = image
            
            sharePostVc.customProductUrl = productUrl
            
            navigationController?.pushViewController(sharePostVc, animated: true)
        }
    }
    
    // MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let searchResults = searchResults
        {
            return searchResults.count + 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0
        {
            let cell: SearchGoogleCell = tableView.dequeueReusableCell(withIdentifier: "SearchGoogleCell") as! SearchGoogleCell
            
            cell.selectionStyle = .none
            
            cell.searchDescriptionLabel.attributedText = NSAttributedString(string: "Don't see what you're looking for?", attributes: [NSFontAttributeName: Font.PrimaryFontLight(size: 12.0),
                                                                                                                                 NSForegroundColorAttributeName: Color.lightGray])
            
            cell.searchGoogleButton.layer.cornerRadius = 4.0
            cell.searchGoogleButton.layer.borderColor = Color.darkGray.cgColor
            cell.searchGoogleButton.layer.borderWidth = 1.0
            
            let attributes = [NSFontAttributeName: Font.PrimaryFontLight(size: 12.0), NSForegroundColorAttributeName: Color.darkGray]
            
            let buttonAttributedString = NSAttributedString(string: "Search Google".uppercased(), attributes: attributes)
            
            cell.searchGoogleButton.setAttributedTitle(buttonAttributedString, for: .normal)
            
            cell.searchGoogleButton.addTarget(self, action: #selector(searchGoogle), for: .touchUpInside)
            
            return cell
        }
        else
        {
            let cell: SearchCell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
            
            cell.resultImageView.image = nil
            cell.titleLabel.text = nil
            
            cell.accessoryType = .disclosureIndicator
            
            cell.titleLabel?.textColor = Color.DarkTextColor
            
            cell.selectionStyle = .default
            
            var resultText: String?
            
            if let searchResults = searchResults
            {
                if let product: SimpleProduct = searchResults[safe: (indexPath as NSIndexPath).row - 1]
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
                var attributedString = NSMutableAttributedString(string: resultText, attributes: FontAttributes.darkBodyTextAttributes)
                
                // Bolden query match
                if let searchQuery = searchBar.text
                {
                    attributedString.boldenMatchesFor(searchQuery)
                }
                
                cell.titleLabel?.attributedText = attributedString
            }
            
            return cell
        }
    }
    
    
    // MARK: Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Did Select Row
        if let product = searchResults?[safe: indexPath.row - 1]
        {
            selectedProduct = product
            
            showFinalShareScreen()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
