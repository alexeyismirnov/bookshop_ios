//
//  CollectionViewController.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 3/29/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

class CollectionViewController : UICollectionViewController, MVCInterface {
    
    var delegate : BooksViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reload() {
        
    }
}
