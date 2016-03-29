//
//  Translate.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

@objc class Translate: NSObject {    

    private static var dict = [String:String]()
    static var defaultLanguage = "en"
    static var locale  = NSLocale(localeIdentifier: "en")
    static var files = [String]()
    
    static var language:String = defaultLanguage {
        didSet {
            // FIXME
            locale = NSLocale(localeIdentifier: "en")
            
            if language == defaultLanguage {
                return
            }
            
            dict = [:]
            
            for (_, file) in files.enumerate() {
                let bundle = NSBundle.mainBundle().pathForResource("\(file)_\(language)", ofType: "plist")
                let newDict = NSDictionary(contentsOfFile: bundle!) as! [String: String]
                
                dict += newDict
            }
        }
    }
    
    static func s(str : String) -> String {
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
