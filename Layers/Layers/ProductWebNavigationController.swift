//
//  ProductWebNavigationController.swift
//  Layers
//
//  Created by David Hodge on 8/12/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

class ProductWebNavigationController: UINavigationController, UIGestureRecognizerDelegate
{
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)
        
        if let popGesture = interactivePopGestureRecognizer
        {
            popGesture.isEnabled = false
            popGesture.delegate = self
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let popGesture = interactivePopGestureRecognizer
        {
            if gestureRecognizer == popGesture
            {
                return false
            }
        }
        
        return true
    }
}
