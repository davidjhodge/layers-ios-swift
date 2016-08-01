//
//  ProductWebViewController.swift
//  Layers
//
//  Created by David Hodge on 4/14/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class ProductWebViewController: UIViewController, UIWebViewDelegate, UITextFieldDelegate
{
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var progressView: FakeProgressView!
    
    var webURL: NSURL?

    var brandName: String?
    
    var couponCode: String?
    
    var couponTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coupon = couponCode
        {
            couponTextField = UITextField(frame: CGRectMake(0, 0, 100.0, 32.0))
            
            if let couponTextField = couponTextField
            {
                couponTextField.text = "   \(coupon)"
                couponTextField.font = Font.OxygenBold(size: 16.0)
                couponTextField.textColor = Color.whiteColor()
                couponTextField.backgroundColor = Color.clearColor()
                
                let imageView = UIImageView(image: UIImage(named: "small-price-tag"))
                imageView.bounds = CGRectMake(0, 0, 10, 18)
                
                couponTextField.leftViewMode = .Always
                couponTextField.leftView = imageView
                
                couponTextField.spellCheckingType = .No
                couponTextField.autocorrectionType = .No
                
                // Placeholder view so keyboard does not show
                couponTextField.inputView = UIView()
                
                couponTextField.delegate = self
            }

            navigationItem.titleView = couponTextField
            
//            title = coupon
        }
        else if let brand = brandName
        {
            title = brand
        }
        
        webView.delegate = self
        
        if let url = webURL
        {
            let request: NSURLRequest = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20.0)
            webView.loadRequest(request)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let couponTextField = couponTextField
        {
            couponTextField.sizeToFit()
        }
        
        // Prevent user from accidentally leaving the page.
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
    
    func startNetworkActivitySpinner()
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func stopNetworkActivitySpinner()
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // MARK: Text Field Delegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return false
    }
    
    // MARK: Web View Delegate
    func webViewDidStartLoad(webView: UIWebView) {
//        spinner.hidden = false
        startNetworkActivitySpinner()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        stopNetworkActivitySpinner()
        
        // Triggers progress load completion
        progressView.isComplete = true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        log.debug(error?.localizedDescription)
        
        stopNetworkActivitySpinner()
        
        let alert: UIAlertController = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: { () -> Void in
         
            
        })

    }
}