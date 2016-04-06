//
//  Model.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 3/30/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

let Firebase_url = "https://torrid-inferno-5814.firebaseio.com"

struct BookData {
    let key: String!
    var title : String!
    var image: String!
    
    init(snapshot: FDataSnapshot) {
        key = snapshot.key
        title = snapshot.value["title"] as! String
        image = snapshot.value["image"] as! String
    }
}

class BooksModel {
    var books : [BookData]!
    
    required init() {
        books = []
    }
    
    func load(completion: () -> Void) {
    }
}

class FirebaseModel : BooksModel {
    let ref = Firebase(url: "\(Firebase_url)/index")
    
    required init() {
        super.init()
    }
    
    override func load(completion: () -> Void) {
        books = []
        
        ref.queryOrderedByChild("date_created").observeEventType(.Value, withBlock: { snapshot in
            var newItems = [BookData]()

            for book in snapshot.children {
                let item = BookData(snapshot: book as! FDataSnapshot)
                newItems.append(item)
            }
            
            self.books = newItems.reverse()
            
            completion()
        })
    }
}

class CoreDataModel : BooksModel {
    required init() {
        super.init()
    }

    override func load(completion: () -> Void) {
        completion()
    }
}



