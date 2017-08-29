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
    case unspecified
    case phone // iPhone and iPod touch style UI
    case pad // iPad style UI
}

func + (arg1: NSMutableAttributedString?, arg2: NSMutableAttributedString?) -> NSMutableAttributedString? {
    
    if let rightArg = arg2 {
        if let leftArg = arg1 {
            let result = NSMutableAttributedString(attributedString: leftArg)
            result.append(rightArg)
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
            result.append(NSMutableAttributedString(string: rightArg))
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
            result.append(NSMutableAttributedString(string: rightArg, attributes: [NSForegroundColorAttributeName: arg2.1]))
            return result
            
        } else {
            return NSMutableAttributedString(string: rightArg, attributes: [NSForegroundColorAttributeName: arg2.1])
        }
        
    } else {
        return arg1
    }
}

func += <K,V> (left: inout Dictionary<K, [V]>, right: Dictionary<K, [V]>) {
    for (k, v) in right {
        if let leftValue = left[k] {
            left.updateValue(v + leftValue, forKey: k)
        } else {
            left.updateValue(v, forKey: k)
        }
    }
}

func +=<K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right { left[k] = v }
}


// http://stackoverflow.com/a/29218836/995049
extension UIColor {
    convenience init(hex: String) {
        let alpha: Float = 100
        
        // Establishing the rgb color
        var rgb: UInt32 = 0
        let s: Scanner = Scanner(string: hex)
        // Setting the scan location to ignore the leading `#`
        s.scanLocation = 1
        // Scanning the int into the rgb colors
        s.scanHexInt32(&rgb)
        
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
    func maskWithColor(_ color: UIColor) -> UIImage {
        
        let maskImage = self.cgImage
        let width = self.size.width
        let height = self.size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let bitmapContext = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        bitmapContext?.clip(to: bounds, mask: maskImage!)
        bitmapContext?.setFillColor(color.cgColor)
        bitmapContext?.fill(bounds)
        
        let cImage = bitmapContext?.makeImage()
        let coloredImage = UIImage(cgImage: cImage!)
        
        return coloredImage
    }
    
    func resize(_ size: CGSize, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        context?.setBlendMode(.normal)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        context?.setBlendMode(.sourceIn)
        color.setFill()
        context?.fill(rect)

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
 
    func resize(_ sizeChange:CGSize)-> UIImage {
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}

extension UIImageView {
    func downloadedFrom(link:String, contentMode mode: UIViewContentMode, cell: UIView) {
        guard let url = URL(string: link) else { return }

        contentMode = mode
        image = nil
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory:URL = urls.first else { return }
        
        if let bundleURL = Bundle.main.url(forResource: url.lastPathComponent, withExtension: "") {
            // print("found in bundle \(link)")
            let data = try! Data(contentsOf: bundleURL)
            image = UIImage(data: data)
            return
        }
        
        let localURL = documentDirectory.appendingPathComponent(url.lastPathComponent)
            
        if (localURL as NSURL).checkResourceIsReachableAndReturnError(nil) {
            let data = try! Data(contentsOf: localURL)
            image = UIImage(data: data)
            return
        }
        
        print("loading \(link)")
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            try? data.write(to: localURL, options: .withoutOverwriting)
            try? (localURL as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
            
            DispatchQueue.main.async { () -> Void in
                self.image = image
                
                cell.setNeedsLayout()
                cell.setNeedsUpdateConstraints()
                cell.setNeedsDisplay()
            }
        }).resume()
    }
}


struct Environment {
    
    static func showNotification(_ title: String, subtitle: String, isError: Bool) {
        
        AJNotificationView.showNotice(in: (UIApplication.shared.delegate?.window)!,
                                            type: isError ? AJNotificationTypeRed : AJNotificationTypeBlue,
                                            title: subtitle,
                                            linedBackground: AJLinedBackgroundTypeAnimated,
                                            hideAfter: 2.0)
    }
    
}


