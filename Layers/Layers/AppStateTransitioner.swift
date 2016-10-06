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
    fileprivate static func transition(_ destinationViewController: UIViewController, animated: Bool)
    {
        let window = UIApplication.shared.delegate!.window!
        
        if animated
        {
            let coverView = UIView(frame: window!.bounds)
            coverView.backgroundColor = UIColor.white
            coverView.alpha = 0.0
            
            window?.addSubview(coverView)
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                coverView.alpha = 1.0
            }, completion: { (finished) -> Void in
                window?.rootViewController = destinationViewController
                window?.bringSubview(toFront: coverView)
                
                
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    coverView.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        coverView.removeFromSuperview()
                })
            }) 
        }
        else
        {
            window?.rootViewController = destinationViewController
        }
    }
    
    static func transitionToLoginStoryboard(_ animated: Bool)
    {
        let storyboard = UIStoryboard(name: "Login", bundle: Bundle.main)
        
        let viewController: UIViewController = storyboard.instantiateInitialViewController()!
        
        transition(viewController, animated: animated)
    }
    
    static func transitionToMainStoryboard(_ animated: Bool)
    {
        transition(mainTabBarController(), animated: animated)
    }
    
    static func mainTabBarController() -> UITabBarController
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let searchStoryboard = UIStoryboard(name: "Search", bundle: Bundle.main)
        let notificationsStoryboard = UIStoryboard(name: "Notifications", bundle: Bundle.main)
        let accountStoryboard = UIStoryboard(name: "Account", bundle: Bundle.main)
        
        let mainVC: UIViewController = mainStoryboard.instantiateInitialViewController()!
        let searchVc: UIViewController = searchStoryboard.instantiateInitialViewController()!
        let notificationsVc: UIViewController = notificationsStoryboard.instantiateInitialViewController()!
        let accountVC: UIViewController = accountStoryboard.instantiateInitialViewController()!
        
        let tabBarController: UITabBarController = UITabBarController()
        tabBarController.viewControllers = [mainVC, searchVc, notificationsVc, accountVC]
        tabBarController.tabBar.isTranslucent = false
        tabBarController.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
        
        return tabBarController
    }
}
