//
//  AppDelegate.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 3/29/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import Firebase
import FolioReaderKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    override init() {
        super.init()
        Firebase.defaultConfig().persistenceEnabled = true
        
         NSUserDefaults.standardUserDefaults().registerDefaults([
            "kNightMode": false,
            "language": "en",
            "firstrun": true,
            "viewType": (UIDevice.currentDevice().userInterfaceIdiom == .Pad) ? "grid" : "list",
            "favorites": []
        ])
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let prefs = NSUserDefaults.standardUserDefaults()
        let firstRun =  (prefs.objectForKey("firstrun") as! Bool)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        Translate.files = ["trans"]
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if firstRun {
            prefs.setObject(false, forKey: "firstrun")
            prefs.synchronize()

            let nav = storyboard.instantiateViewControllerWithIdentifier("OptionsNav") as! UINavigationController
            (nav.topViewController as! OptionsViewController).firstRun = true
            window?.rootViewController = nav
            
        } else {
            window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("MainView")
            
        }
        window?.makeKeyAndVisible()
        
        Appirater.setAppId("1105252815")
        Appirater.setDaysUntilPrompt(5)
        Appirater.setUsesUntilPrompt(5)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(2)
        Appirater.setDebug(false)
        Appirater.appLaunched(true)
        
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        Appirater.appEnteredForeground(true)
    }

}

