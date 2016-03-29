//
//  AppDelegate.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 3/29/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if prefs.objectForKey("language") == nil {
            
            prefs.setObject("en", forKey: "language")
            prefs.setObject("viewType", forKey: "list")
        }
        
        let language = prefs.objectForKey("language") as! String
        Translate.language = language
        
        return true
    }


}

