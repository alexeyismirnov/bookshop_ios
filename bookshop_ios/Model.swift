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
    var books = [BookData]()
    
    required init() {
    }
    
    func load(completion: () -> Void) {
    }
    
    func updateFavorites() {
        
    }
}

class FirebaseModel : BooksModel {
    let ref = Firebase(url: "\(Firebase_url)/index")
    let prefs = NSUserDefaults.standardUserDefaults()
    var orig_books = [BookData]()
    
    override func load(completion: () -> Void) {
        books = []

        ref.queryOrderedByChild("date_created").observeEventType(.Value, withBlock: { snapshot in
            var newItems = [BookData]()

            for book in snapshot.children {
                let item = BookData(snapshot: book as! FDataSnapshot)
                newItems.append(item)
            }
            
            self.books = newItems.reverse()
            self.orig_books = self.books
            self.updateFavorites()

            completion()
        })
    }
    
    override func updateFavorites() {
        let favorites = prefs.arrayForKey("favorites") as! [String]

        books = orig_books
        
        for i in self.books.indices {
            if favorites.contains(books[i].key) {
                books[i].favorite = true
            }
        }
    }
}

class CoreDataModel : FirebaseModel {
    override func updateFavorites() {
        let favorites = self.prefs.arrayForKey("favorites") as! [String]
        
        books = orig_books.filter() { book in
            favorites.contains(book.key)
        }
        
        for i in books.indices {
            books[i].favorite = false
        }
    }
}

