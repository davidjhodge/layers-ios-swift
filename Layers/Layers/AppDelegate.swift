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

import AWSSNS

let log = SwiftyBeaver.self

private let facebookScheme: String = "fb982100215236828"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
//        print(UIDevice.currentDevice().identifierForVendor!.UUIDString)
        
        window = LRWindow(frame: UIScreen.mainScreen().bounds)
        window?.tintColor = Color.DarkNavyColor
        
        // Swifty Beaver
        log.addDestination(ConsoleDestination())
        
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).translucent = false
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).barTintColor = Color.DarkNavyColor
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).tintColor = Color.whiteColor()
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).titleTextAttributes = [NSForegroundColorAttributeName: Color.whiteColor(),
                                                                                                            NSFontAttributeName: Font.OxygenBold(size: 16.0)]
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).setTitleTextAttributes([NSForegroundColorAttributeName: Color.whiteColor(),
            NSFontAttributeName: Font.OxygenRegular(size: 16.0)], forState: .Normal)
        
        UITableViewCell.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).tintColor = Color.DarkNavyColor
        
        // Determine intial view controller based on login state
        
        AppStateTransitioner.transitionToMainStoryboard(false)
        
//        if LRSessionManager.sharedManager.isLoggedIn()
//        {
//            AppStateTransitioner.transitionToMainStoryboard(false)
//        }
//        else
//        {
//            AppStateTransitioner.transitionToLoginStoryboard(false)
//        }

        window?.makeKeyAndVisible()
                
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        tempRegisterForNotifications()
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        if let cognitoId = LRSessionManager.sharedManager.credentialsProvider?.identityId
        {
            let kAWSSNSApplicationARN = "arn:aws:sns:us-west-2:520777401565:app/APNS_SANDBOX/Layers"
            
            let platformEndpointRequest = AWSSNSCreatePlatformEndpointInput()
            platformEndpointRequest.customUserData = "need to add user data"
            platformEndpointRequest.token = deviceTokenAsString(deviceToken)
            platformEndpointRequest.platformApplicationArn = kAWSSNSApplicationARN
            
            let snsManager = AWSSNS.defaultSNS()
            
            snsManager.createPlatformEndpoint(platformEndpointRequest)
        }
    }
    
    func deviceTokenAsString(tokenData: NSData) -> String
    {
        let rawDeviceString: String = "\(tokenData)"
        
        let noSpaces = rawDeviceString.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        let temp: String = noSpaces.stringByReplacingOccurrencesOfString("<", withString: "")
        
        return temp.stringByReplacingOccurrencesOfString(">", withString: "")
    }
    
    func tempRegisterForNotifications()
    {
                let readAction: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
                readAction.identifier = "READ_IDENTIFIER"
                readAction.title = "Read"
                readAction.activationMode = .Foreground
                readAction.destructive = false
        readAction.authenticationRequired = true
        
        let messageCategory = UIMutableUserNotificationCategory()
        messageCategory.identifier = "MESSAGE_CATEGORY"
        messageCategory.setActions([readAction], forContext: .Default)
        messageCategory.setActions([readAction], forContext: .Minimal)
        
        let categories: Set<UIUserNotificationCategory> = NSSet(object: messageCategory) as! Set<UIUserNotificationCategory>
        
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: categories)
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }

        func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        application.applicationIconBadgeNumber = 0
        let message = userInfo
        print(message)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
       
        if url.scheme == facebookScheme
        {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        return true
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

