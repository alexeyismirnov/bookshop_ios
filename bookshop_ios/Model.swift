//
//  Model.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 3/30/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

let Firebase_url = "https://torrid-inferno-5814.firebaseio.com"

struct BookData {
    let key: String!
    var title = [String:String!]()
    var image: String!
    var download_url: String!
    var epub_url: String?
    var favorite : Bool = false
    
    init(snapshot:DataSnapshot) {
        key = snapshot.key
        //let value = snapshot.value
        //print(value)
        let dict = snapshot.value as! [String: String]

        for lang in languages {
            title[lang] = dict["title_\(lang)"]
        }
        
        image = dict["image"]
        download_url = dict["download_url"]
        epub_url = dict["epub_url"]
    }
    
    }

class BooksModel {
    var books = [BookData]()
    
    required init() {
    }
    
    func load(_ completion: @escaping () -> Void) {
    }
    
    func updateFavorites() {
        
    }
}

class FirebaseModel : BooksModel {
    let ref = Database.database().reference().child("index")
    let prefs = UserDefaults.standard
    var orig_books = [BookData]()
    
    override func load(_ completion: @escaping () -> Void) {
        books = []

        ref.queryOrdered(byChild: "date_created").observe(.value, with: { snapshot in
            var newItems = [BookData]()

            for book in snapshot.children {
                let item = BookData(snapshot: book as! DataSnapshot)
                newItems.append(item)
            }
            
            self.books = newItems.reversed()
            self.orig_books = self.books
            self.updateFavorites()

            completion()
        })
    }
    
    override func updateFavorites() {
        let favorites = prefs.array(forKey: "favorites") as! [String]

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
        let favorites = self.prefs.array(forKey: "favorites") as! [String]
        
        books = orig_books.filter() { book in
            favorites.contains(book.key)
        }
        
        for i in books.indices {
            books[i].favorite = false
        }
    }
}

