//
//  AppDelegate.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import SwiftyBeaver
import FBSDKCoreKit
import DeepLinkKit
import ObjectMapper
//import Fabric
//import Crashlytics

let log = SwiftyBeaver.self

private let facebookScheme: String = "fb982100215236828"
private let layersScheme: String = "trylayers"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    lazy var router = DPLDeepLinkRouter()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Crashlytics
        //Fabric.with([Crashlytics.self])
        
        window = LRWindow(frame: UIScreen.main.bounds)
        window?.tintColor = Color.PrimaryAppColor
        
        // Swifty Beaver
        log.addDestination(ConsoleDestination())
        
        // UIApperance
        configureDefaultAppearances()
        
        // Deep Linking
        registerRoutes()
        
        // Determine intial view controller based on FirstLaunchExperience        
//        if LRSessionManager.sharedManager.hasCompletedFirstLaunch() == true
//        {
//            if LRSessionManager.sharedManager.hasCredentials()
//            {
//                AppStateTransitioner.transitionToMainStoryboard(false)
//            }
//            else
//            {
//                AppStateTransitioner.transitionToLoginStoryboard(false)
//            }
//        }
//        else
//        {
            AppStateTransitioner.transitionToMainStoryboard(false)
//        }

        window?.makeKeyAndVisible()
                
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
                
        return true
    }
    
    func configureDefaultAppearances()
    {
        UINavigationBar.appearance(whenContainedInInstancesOf: [LRWindow.self]).isTranslucent = false
        UINavigationBar.appearance(whenContainedInInstancesOf: [LRWindow.self]).setBackgroundImage(UIButton.imageFromColor(Color.PrimaryAppColor), for: .default)
        UINavigationBar.appearance(whenContainedInInstancesOf: [LRWindow.self]).tintColor = Color.white
        UINavigationBar.appearance(whenContainedInInstancesOf: [LRWindow.self]).titleTextAttributes = [NSForegroundColorAttributeName: Color.white,
                                                                                                            NSFontAttributeName: Font.PrimaryFontRegular(size: 16.0),
                                                                                                            NSKernAttributeName:1.5]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [LRWindow.self]).setTitleTextAttributes([NSForegroundColorAttributeName: Color.white,
            NSFontAttributeName: Font.PrimaryFontLight(size: 16.0)], for: UIControlState())
        
        UITableViewCell.appearance(whenContainedInInstancesOf: [LRWindow.self]).tintColor = Color.PrimaryAppColor
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSFontAttributeName: Font.PrimaryFontLight(size: 12.0), NSForegroundColorAttributeName: Color.DarkTextColor, NSKernAttributeName: 0.7]
    }
    
    func registerRoutes()
    {
        router["products/:product_id"] = ProductRouteHandler.self
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
//        LRSessionManager.sharedManager.registerForPushNotifications(deviceToken, completionHandler: { (success, error, response) -> Void in
//         
//            if success
//            {
//                NotificationCenter.default.post(Notification(name: kUserDidRegisterForNotifications, object: nil))
//            }
//            else
//            {
//                log.error(error)
//            }
//        })
    }

        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
            application.applicationIconBadgeNumber = 0
            
            if let productId = userInfo["product_id"] as? String
            {
                // Mimicking an outbound Url to use Routing functionality. This should be improved in the future.
                router.handle(URL(string: "trylayers://products/\(productId)"), withCompletion: nil)
            }
            
        let message = userInfo
        print(message)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        if url.scheme == facebookScheme
        {
            if let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, let annotation = options[UIApplicationOpenURLOptionsKey.openInPlace]
            {
                return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
            }
        }
        else if url.scheme == layersScheme
        {
            router.handle(url, withCompletion: nil)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
       
        if url.scheme == facebookScheme
        {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        else if url.scheme == layersScheme
        {
            // Handle Route
            AppStateTransitioner.transitionToMainStoryboard(false)
            
            router.handle(url, withCompletion: nil)
        }
        
        return true
    }
    
    // For future verisons where universal links are supported
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        return router.handle(userActivity, withCompletion: nil)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

