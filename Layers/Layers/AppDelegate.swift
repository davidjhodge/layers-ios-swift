//
//  AppDelegate.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import SwiftyBeaver

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        window = LRWindow(frame: UIScreen.mainScreen().bounds)
        window?.tintColor = Color.DarkNavyColor
        
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).translucent = false
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).barTintColor = Color.DarkNavyColor
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).tintColor = Color.whiteColor()
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LRWindow.self]).titleTextAttributes = [NSForegroundColorAttributeName: Color.whiteColor(),
                                                                                                            NSFontAttributeName: Font.CharterBold(size: 20.0),
                                                                                                            NSKernAttributeName: 3.0]

        AppStateTransitioner.transitionToLoginStoryboard(false)
//        AppStateTransitioner.transitionToMainStoryboard(false)

        window?.makeKeyAndVisible()
        
//        for family: String in UIFont.familyNames()
//        {
//            print("\(family)")
//            for names: String in UIFont.fontNamesForFamilyName(family)
//            {
//                print("== \(names)")
//            }
//        }
        
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

