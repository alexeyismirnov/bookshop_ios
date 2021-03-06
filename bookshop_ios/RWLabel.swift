//
//  RWLabel.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 27.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

class RWLabel : UILabel {
    override var bounds : CGRect {
        didSet {
            if numberOfLines == 0 && bounds.size.width != preferredMaxLayoutWidth {
                preferredMaxLayoutWidth = self.bounds.size.width
                DispatchQueue.main.async(execute: {
                    self.setNeedsUpdateConstraints()
                    self.setNeedsDisplay()

                })

                
            }
        }
    }
}
