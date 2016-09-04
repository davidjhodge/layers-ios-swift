//
//  ProductWebViewController.swift
//  Layers
//
//  Created by David Hodge on 8/12/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class ProductWebViewController: SFSafariViewController, SFSafariViewControllerDelegate
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = Color.PrimaryAppColor
        
        modalPresentationStyle = .OverFullScreen
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return .Default
    }
    
    // MARK: SFSafariViewControllerDelegate
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}