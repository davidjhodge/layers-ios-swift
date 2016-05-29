//
//  AppStateTransitioner.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class AppStateTransitioner
{
    private static func transition(destinationViewController: UIViewController, animated: Bool)
    {
        let window = UIApplication.sharedApplication().delegate!.window!
        
        if animated
        {
            let coverView = UIView(frame: window!.bounds)
            coverView.backgroundColor = UIColor.whiteColor()
            coverView.alpha = 0.0
            
            window?.addSubview(coverView)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                coverView.alpha = 1.0
            }) { (finished) -> Void in
                window?.rootViewController = destinationViewController
                window?.bringSubviewToFront(coverView)
                
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    coverView.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        coverView.removeFromSuperview()
                })
            }
        }
        else
        {
            window?.rootViewController = destinationViewController
        }
    }
    
    static func transitionToLoginStoryboard(animated: Bool)
    {
        let storyboard = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
        
        let viewController: UIViewController = storyboard.instantiateInitialViewController()!
        
        transition(viewController, animated: animated)
    }
    
    static func transitionToMainStoryboard(animated: Bool)
    {
        transition(mainTabBarController(), animated: animated)
    }
    
    static func mainTabBarController() -> UITabBarController
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let priceAlertsStoryboard = UIStoryboard(name: "PriceAlerts", bundle: NSBundle.mainBundle())
        let accountStoryboard = UIStoryboard(name: "Account", bundle: NSBundle.mainBundle())
        
        let mainVC: UIViewController = mainStoryboard.instantiateInitialViewController()!
        let priceAlertsVC: UIViewController = priceAlertsStoryboard.instantiateInitialViewController()!
        let accountVC: UIViewController = accountStoryboard.instantiateInitialViewController()!
        
        let tabBarController: UITabBarController = UITabBarController()
        tabBarController.viewControllers = [mainVC, priceAlertsVC, accountVC]
        tabBarController.tabBar.translucent = false
        tabBarController.delegate = UIApplication.sharedApplication().delegate as? UITabBarControllerDelegate
        
        return tabBarController
    }
}