//
//  Model.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 3/30/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import Firebase

let Firebase_url = "https://torrid-inferno-5814.firebaseio.com"

struct BookData {
    let key: String!
    var title = [String:String!]()
    var image: String!
    var download_url: String!
    var epub_url: String?
    var favorite : Bool = false
    
    init(snapshot: FDataSnapshot) {
        key = snapshot.key
        
        for lang in languages {
            title[lang] = snapshot.value["title_\(lang)"] as! String
        }
        
        image = snapshot.value["image"] as! String
        download_url = snapshot.value["download_url"] as! String
        epub_url = snapshot.value["epub_url"] as? String
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
    let prefs = NSUserDefaults.standardUserDefaults()

    required init() {
        super.init()
    }
    
    override func load(completion: () -> Void) {
        let favorites = self.prefs.arrayForKey("favorites") as! [String]

        books = []

        ref.queryOrderedByChild("date_created").observeEventType(.Value, withBlock: { snapshot in
            var newItems = [BookData]()

            for book in snapshot.children {
                var item = BookData(snapshot: book as! FDataSnapshot)
                
                if favorites.contains(book.key) {
                    item.favorite = true
                }
                
                newItems.append(item)
            }
            
            self.books = newItems.reverse()
            
            completion()
        })
    }
}

class CoreDataModel : FirebaseModel {
    required init() {
        super.init()
    }

    override func load(completion: () -> Void) {
        super.load() { _ in
            
            let favorites = self.prefs.arrayForKey("favorites") as! [String]

            self.books = self.books.filter() { book in
                favorites.contains(book.key)
            }

            for i in self.books.indices {
                self.books[i].favorite = false
            }
            
            completion()
        }
    }
}

