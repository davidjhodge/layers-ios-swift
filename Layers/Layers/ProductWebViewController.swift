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

    let spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        //TEMP
        webURL = NSURL(string: "https://www.jcrew.com/mens_feature/NewArrivals/shirts/PRDOVR~E7999/E7999.jsp")
        
        if let url = webURL
        {
            let request: NSURLRequest = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20.0)
            webView.loadRequest(request)
        }
        
        spinner.hidesWhenStopped = true
        navigationItem.rightBarButtonItem?.customView = spinner
    }

    // MARK: Actions
    @IBAction func back(sender: AnyObject)
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Web View Delegate
    func webViewDidStartLoad(webView: UIWebView) {
//        spinner.hidden = false
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        spinner.stopAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        log.debug(error?.localizedDescription)
        
        let alert: UIAlertController = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)

    }
}