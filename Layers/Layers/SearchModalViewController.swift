//
//  SearchModalViewController.swift
//  Layers
//
//  Created by David Hodge on 5/10/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class SearchModalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
{
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    var searchResults: Array<ProductResponse>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        tableView.tableFooterView = UIView()
        
        cancelButton.addTarget(self, action: #selector(cancel), forControlEvents: .TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)

        searchBar.becomeFirstResponder()
    }

    // MARK: Search Bar Delegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText.characters.count == 0
        {
            tableView.reloadData()
        }
        else
        {
            // Send API Query
            
            // TEMP
            let queryString = searchText
            let page = queryString.characters.count
            
            LRSessionManager.sharedManager.loadProductCollection(page, completionHandler: { (success, error, response) -> Void in
                
                if success
                {
                    if let results = response as? Array<ProductResponse>
                    {
                        self.searchResults = results
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                          
                            self.tableView.reloadData()
                        })
                    }
                }
                else
                {
                    let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func cancel()
    {
        view.endEditing(true)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    
    
    // MARK: UITableView Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let results = searchResults
        {
            return results.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell")!
        
        cell.textLabel?.text = ""
        
        cell.textLabel?.font = Font.OxygenRegular(size: 14.0)
        
        if let products = searchResults
        {
            let product = products[indexPath.row]
            
            if let productName = product.productName, brandName = product.brand?.brandName
            {
                cell.textLabel?.text = "\(brandName) \(productName)"
            }
        }
        
        return cell
    }
    
    // MARK: UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // didSelectRowAtIndexPath

        performSegueWithIdentifier("ShowProductViewController", sender: indexPath)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowProductViewController"
        {
            if let indexPath = sender as? NSIndexPath
            {
                if let selectedProduct: ProductResponse = searchResults?[safe: indexPath.row]
                {
                    if let destinationVc = segue.destinationViewController as? ProductViewController
                    {
                        destinationVc.productIdentifier = selectedProduct.productId
                    }
                }

            }
        }
    }
}