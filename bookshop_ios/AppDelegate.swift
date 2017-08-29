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
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
                
         UserDefaults.standard.register(defaults: [
            "kNightMode": false,
            "language": "en",
            "firstrun": true,
            "viewType": (UIDevice.current.userInterfaceIdiom == .pad) ? "grid" : "list",
            "favorites": []
        ])
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let prefs = UserDefaults.standard
        let firstRun =  (prefs.object(forKey: "firstrun") as! Bool)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        Translate.files = ["trans"]
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if firstRun {
            prefs.set(false, forKey: "firstrun")
            prefs.synchronize()

            let nav = storyboard.instantiateViewController(withIdentifier: "OptionsNav") as! UINavigationController
            (nav.topViewController as! OptionsViewController).firstRun = true
            window?.rootViewController = nav
            
        } else {
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "MainView")
            
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
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Appirater.appEnteredForeground(true)
    }

}

