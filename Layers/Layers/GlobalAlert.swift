//
//  GlobalAlert.swift
//  Layers
//
//  Created by David Hodge on 6/18/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController
{
    func show()
    {
        present(true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?)
    {
        if let rootVc = UIApplication.sharedApplication().keyWindow?.rootViewController
        {
            presentFromController(rootVc, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?)
    {
        if let navVc = controller as? UINavigationController,
        let visibleVc = navVc.visibleViewController
        {
            presentFromController(visibleVc, animated: animated, completion: completion)
        }
        else if let tabVc = controller as? UITabBarController,
        let selectedVc = tabVc.selectedViewController
        {
            presentFromController(selectedVc, animated: animated, completion: completion)
        }
        else
        {
            controller.presentViewController(self, animated: animated, completion: completion)
        }
    }
}