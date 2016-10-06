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
        
        modalPresentationStyle = .overFullScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return .default
    }
    
    // MARK: SFSafariViewControllerDelegate
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        dismiss(animated: true, completion: nil)
    }
}
