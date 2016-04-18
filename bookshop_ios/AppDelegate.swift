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
            "viewType": (UIDevice.currentDevice().userInterfaceIdiom == .Pad) ? "grid" : "list",
            "favorites": []
        ])
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
 
        Translate.files = ["trans"]
        
        return true
    }


}

