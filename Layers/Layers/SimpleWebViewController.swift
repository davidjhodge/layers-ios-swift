//
//  SimpleWebViewController.swift
//  Layers
//
//  Created by David Hodge on 4/10/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class SimpleWebViewController: UIViewController, UIWebViewDelegate
{
    @IBOutlet weak var webView: UIWebView!
    
    let spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
    
    var webURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.whiteColor()
        
        spinner.hidesWhenStopped = true
        spinner.hidden = true
        navigationItem.rightBarButtonItem?.customView = spinner
        
        if let url = webURL
        {
            let request: NSURLRequest = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20.0)
            webView.loadRequest(request)
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        
        spinner.hidden = false
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        spinner.stopAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        let alert: UIAlertController = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}