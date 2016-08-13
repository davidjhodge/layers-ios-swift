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
    override func setNavigationBarHidden(hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)
        
        if let popGesture = interactivePopGestureRecognizer
        {
            popGesture.enabled = false
            popGesture.delegate = self
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
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