//
//  Translate.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

@objc class Translate: NSObject {    

    fileprivate static var dict = [String:String]()
    static var defaultLanguage = "en"
    static var locale  = Locale(identifier: "en")

    static var files = [String]() {
        didSet {
            reloadFiles()
        }
    }
    
    static var language = UserDefaults.standard.string(forKey: "language")!  {
        didSet {
            reloadFiles()
        }
    }
    
    static func reloadFiles() {
        // FIXME
        locale = Locale(identifier: "en")
        
        if language == defaultLanguage {
            return
        }
        
        dict = [:]
        
        for file in files {
            let bundle = Bundle.main.path(forResource: "\(file)_\(language)", ofType: "plist")
            let newDict = NSDictionary(contentsOfFile: bundle!) as! [String: String]
            dict += newDict
        }
        
    }
    
    static func s(_ str : String) -> String {
        if language == defaultLanguage {
            return str
        }
        
        if let trans_str = dict[str] as String!  {
            return trans_str
        } else {
            return str
        }
    }
    
}
