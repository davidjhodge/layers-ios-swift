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
import Fabric
import Crashlytics

let log = SwiftyBeaver.self

private let facebookScheme: String = "fb982100215236828"
private let layersScheme: String = "trylayers"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    lazy var router = DPLDeepLinkRouter()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //Crashlytics
        Fabric.with([Crashlytics.self])
        
        window = LRWindow(frame: UIScreen.mainScreen().bounds)
        window?.tintColor = Color.DarkNavyColor
        
        // Swifty Beaver
        log.addDestination(ConsoleDestination())
        
        // UIApperance
        configureDefaultAppearances()
        
        // Deep Linking
        registerRoutes()
        
        // Determine intial view controller based on FirstLaunchExperience        
        if LRSessionManager.sharedManager.hasCompletedFirstLaunch() == true
        {
            if LRSessionManager.sharedManager.hasCredentials()
            {
                AppStateTransitioner.transitionToMainStoryboard(false)
            }
            else
            {
                AppStateTransitioner.transitionToLoginStoryboard(false)
            }
        }
        else
        {
            AppStateTransitioner.transitionToLoginStoryboard(false)
        }

        window?.makeKeyAndVisible()
                
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
                
        return true
    }
    
    func configureDefaultAppearances()
    {
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).translucent = false
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).setBackgroundImage(UIImage.navigationBarImage(), forBarMetrics: .Default)
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).tintColor = Color.whiteColor()
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).titleTextAttributes = [NSForegroundColorAttributeName: Color.whiteColor(),
                                                                                                            NSFontAttributeName: Font.OxygenBold(size: 16.0)]
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).setTitleTextAttributes([NSForegroundColorAttributeName: Color.whiteColor(),
            NSFontAttributeName: Font.OxygenRegular(size: 16.0)], forState: .Normal)
        
        UITableViewCell.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).tintColor = Color.DarkNavyColor
    }
    
    func registerRoutes()
    {
        router["products/:product_id"] = ProductRouteHandler.self
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        LRSessionManager.sharedManager.registerForPushNotifications(deviceToken, completionHandler: { (success, error, response) -> Void in
         
            if success
            {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kUserDidRegisterForNotifications, object: nil))
            }
            else
            {
                log.error(error)
            }
        })
    }

        func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
            application.applicationIconBadgeNumber = 0
            
            if let productId = userInfo["product_id"] as? String
            {
                // Mimicking an outbound Url to use Routing functionality. This should be improved in the future.
                router.handleURL(NSURL(string: "trylayers://products/\(productId)"), withCompletion: nil)
            }
            
        let message = userInfo
        print(message)
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        if url.scheme == facebookScheme
        {
            if let sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String, let annotation = options[UIApplicationOpenURLOptionsOpenInPlaceKey]
            {
                return FBSDKApplicationDelegate.sharedInstance().application(app, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
            }
        }
        else if url.scheme == layersScheme
        {
            router.handleURL(url, withCompletion: nil)
        }
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
       
        if url.scheme == facebookScheme
        {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        else if url.scheme == layersScheme
        {
            // Handle Route
            AppStateTransitioner.transitionToMainStoryboard(false)
            
            router.handleURL(url, withCompletion: nil)
        }
        
        return true
    }
    
    // For future verisons where universal links are supported
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        
        return router.handleUserActivity(userActivity, withCompletion: nil)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

