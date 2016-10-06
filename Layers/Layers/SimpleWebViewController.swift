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
    
    let spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    var webURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.white
        
        spinner.hidesWhenStopped = true
        spinner.isHidden = true
        navigationItem.rightBarButtonItem?.customView = spinner
        
        if let url = webURL
        {
            let request: URLRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20.0)
            webView.loadRequest(request)
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        spinner.isHidden = false
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        spinner.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        let alert: UIAlertController = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
