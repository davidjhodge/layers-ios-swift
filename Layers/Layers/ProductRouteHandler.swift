//
//  ProductRouteHandler.swift
//  Layers
//
//  Created by David Hodge on 5/28/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import DeepLinkKit

open class ProductRouteHandler: DPLRouteHandler
{
    var tabBarController: UITabBarController?
    
    func getTabBarController() -> UITabBarController?
    {
        var tabBarVc: UITabBarController?
        
        // If Tab Bar Controller is already rootVc, nothing needs to change
        if let rootVc = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController
        {
            tabBarVc = rootVc
            
            tabBarVc?.selectedIndex = 0
        }
            // If UITabBarController is not the rootViewController, we create one and make it the root vc
        else
        {
            tabBarVc = AppStateTransitioner.mainTabBarController()
            
            UIApplication.shared.keyWindow?.rootViewController = tabBarVc
        }
        
        return tabBarVc
    }
    
    // The view controller to be displayed
    open override func targetViewController() -> UIViewController! {

        if tabBarController != nil
        {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            
            if let productVc = storyboard.instantiateViewController(withIdentifier: "ProductViewController") as? ProductViewController
            {
                return productVc
            }
        }
        
        return UIViewController()
    }
    
    // The view controller that will present the target vc. Should be UINavigationController
    open override func viewController(forPresenting deepLink: DPLDeepLink!) -> UIViewController! {
        
        if tabBarController == nil
        {
            tabBarController = getTabBarController()
        }
        
        if let navController = tabBarController?.childViewControllers[safe: 0] as? UINavigationController
        {
            return navController
        }
        
        return UINavigationController()
    }
    
    open override func preferModalPresentation() -> Bool {
        return false
    }
}
