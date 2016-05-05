//
//  Extensions.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 03.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import AJNotificationView

enum UIUserInterfaceIdiom : Int {
    case Unspecified
    case Phone // iPhone and iPod touch style UI
    case Pad // iPad style UI
}

func + (arg1: NSMutableAttributedString?, arg2: NSMutableAttributedString?) -> NSMutableAttributedString? {
    
    if let rightArg = arg2 {
        if let leftArg = arg1 {
            let result = NSMutableAttributedString(attributedString: leftArg)
            result.appendAttributedString(rightArg)
            return result
            
        } else {
            return arg2
        }
        
    } else {
        return arg1
    }
    
}

func + (arg1: NSMutableAttributedString?, arg2: String?) -> NSMutableAttributedString? {
    
    if let rightArg = arg2 {
        if let leftArg = arg1 {
            let result = NSMutableAttributedString(attributedString: leftArg)
            result.appendAttributedString(NSMutableAttributedString(string: rightArg))
            return result
            
        } else {
            return NSMutableAttributedString(string: rightArg)
        }
        
    } else {
        return arg1
    }
}

func + (arg1: NSMutableAttributedString?, arg2: (String?, UIColor)) -> NSMutableAttributedString? {
    
    if let rightArg = arg2.0 {
        if let leftArg = arg1 {
            let result = NSMutableAttributedString(attributedString: leftArg)
            result.appendAttributedString(NSMutableAttributedString(string: rightArg, attributes: [NSForegroundColorAttributeName: arg2.1]))
            return result
            
        } else {
            return NSMutableAttributedString(string: rightArg, attributes: [NSForegroundColorAttributeName: arg2.1])
        }
        
    } else {
        return arg1
    }
}

func += <K,V> (inout left: Dictionary<K, [V]>, right: Dictionary<K, [V]>) {
    for (k, v) in right {
        if let leftValue = left[k] {
            left.updateValue(v + leftValue, forKey: k)
        } else {
            left.updateValue(v, forKey: k)
        }
    }
}

func +=<K, V> (inout left: [K:V], right: [K:V]) {
    for (k, v) in right { left[k] = v }
}


// http://stackoverflow.com/a/29218836/995049
extension UIColor {
    convenience init(hex: String) {
        let alpha: Float = 100
        
        // Establishing the rgb color
        var rgb: UInt32 = 0
        let s: NSScanner = NSScanner(string: hex)
        // Setting the scan location to ignore the leading `#`
        s.scanLocation = 1
        // Scanning the int into the rgb colors
        s.scanHexInt(&rgb)
        
        // Creating the UIColor from hex int
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha / 100)
        )
    }
  
    static func lightBlueColor() -> UIColor {
        return UIColor.init(hex: "#007AFF")
    }

}

extension UIImage {
    func maskWithColor(color: UIColor) -> UIImage {
        
        let maskImage = self.CGImage
        let width = self.size.width
        let height = self.size.height
        let bounds = CGRectMake(0, 0, width, height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let bitmapContext = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, colorSpace, bitmapInfo.rawValue)
        
        CGContextClipToMask(bitmapContext, bounds, maskImage)
        CGContextSetFillColorWithColor(bitmapContext, color.CGColor)
        CGContextFillRect(bitmapContext, bounds)
        
        let cImage = CGBitmapContextCreateImage(bitmapContext)
        let coloredImage = UIImage(CGImage: cImage!)
        
        return coloredImage
    }
    
    func resize(size: CGSize, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRectMake(0, 0, size.width, size.height)
        
        CGContextSetBlendMode(context, .Normal)
        drawInRect(CGRect(origin: CGPointZero, size: size))
        
        CGContextSetBlendMode(context, .SourceIn)
        color.setFill()
        CGContextFillRect(context, rect)

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
 
    func resize(sizeChange:CGSize)-> UIImage {
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}

extension UIImageView {
    func downloadedFrom(link link:String, contentMode mode: UIViewContentMode, cell: UIView) {
        guard let url = NSURL(string: link) else { return }

        contentMode = mode
        image = nil
        
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        guard let documentDirectory:NSURL = urls.first else { return }
        
        if let bundleURL = NSBundle.mainBundle().URLForResource(url.lastPathComponent!, withExtension: "") {
            // print("found in bundle \(link)")
            let data = NSData(contentsOfURL: bundleURL)!
            image = UIImage(data: data)
            return
        }
        
        let localURL = documentDirectory.URLByAppendingPathComponent(url.lastPathComponent!)
            
        if localURL.checkResourceIsReachableAndReturnError(nil) {
            let data = NSData(contentsOfURL: localURL)!
            image = UIImage(data: data)
            return
        }
        
        print("loading \(link)")
        
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            
            try? data.writeToURL(localURL, options: .DataWritingWithoutOverwriting)
            try? localURL.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.image = image
                
                cell.setNeedsLayout()
                cell.setNeedsUpdateConstraints()
                cell.setNeedsDisplay()
            }
        }).resume()
    }
}


struct Environment {
    
    static func showNotification(title: String, subtitle: String, isError: Bool) {
        
        AJNotificationView.showNoticeInView((UIApplication.sharedApplication().delegate?.window)!,
                                            type: isError ? AJNotificationTypeRed : AJNotificationTypeBlue,
                                            title: subtitle,
                                            linedBackground: AJLinedBackgroundTypeAnimated,
                                            hideAfter: 2.0)
    }
    
}


