//
//  ProductWebViewController.swift
//  Layers
//
//  Created by David Hodge on 4/14/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class ProductWebViewController: UIViewController, UIWebViewDelegate
{
    @IBOutlet weak var webView: UIWebView!
    
    var webURL: NSURL?

    var brandName: String?
    
    let spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let brand = brandName
        {
            title = brand
        }
        
        webView.delegate = self
        
        if let url = webURL
        {
            let request: NSURLRequest = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20.0)
            webView.loadRequest(request)
        }
        
        spinner.hidesWhenStopped = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.enabled = false
}
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.enabled = true
    }

    // MARK: Actions
    @IBAction func back(sender: AnyObject)
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
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
    
    // MARK: Web View Delegate
    func webViewDidStartLoad(webView: UIWebView) {
//        spinner.hidden = false
        startNetworkActivitySpinners()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        stopNetworkActivitySpinners()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        log.debug(error?.localizedDescription)
        
        stopNetworkActivitySpinners()
        
        let alert: UIAlertController = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: { () -> Void in
         
            
        })

    }
}