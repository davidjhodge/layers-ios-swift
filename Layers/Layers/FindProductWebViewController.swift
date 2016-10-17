//
//  FindProductWebViewController.swift
//  Layers
//
//  Created by David Hodge on 10/16/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

protocol CustomProductDelegate {
    func customProduct(_ image: UIImage, productUrl: URL)
}

class FindProductWebViewController: UIViewController, UIWebViewDelegate, SelectImageDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    var customProductDelegate: CustomProductDelegate?
    
    var searchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Find the Product Page"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(selectPhoto))
        
        webView.scalesPageToFit = true
        
        loadWebPage()
    }
    
    func loadWebPage()
    {
        var urlString = "https://www.google.com/"
        
        if let queryString = searchText?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        {
            urlString += "search?q=\(queryString)"
        }
        
        if let url = URL(string: urlString)
        {
            let request = URLRequest(url: url)
                
            webView.loadRequest(request)
        }
    }
    
    func selectPhoto()
    {
        if let currentUrlString = webView.request?.url?.absoluteString
        {
            // If Google is the webpage, fail
            if currentUrlString.range(of: "www.google.com") != nil
            {
                return
            }
            
            let storyboard = UIStoryboard(name: "Upload", bundle: Bundle.main)
            
            if let selectImageVc = storyboard.instantiateViewController(withIdentifier: "SelectImageViewController") as? SelectImageViewController
            {
                selectImageVc.images = HTMLImageParser.imagesAtUrlString(currentUrlString)
                
                selectImageVc.selectImageDelegate = self
                
                navigationController?.pushViewController(selectImageVc, animated: true)
            }
        }
    }
    
    // MARK: Select Image Delegate
    func imageSelected(_ image: UIImage) {
        
        if let webUrlString = webView.request?.url?.absoluteString
        {
            if let webUrl = URL(string: webUrlString)
            {
                customProductDelegate?.customProduct(image, productUrl: webUrl)
            }
        }
    }
    
    // MARK: Web View Delegate
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
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
