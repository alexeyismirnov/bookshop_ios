//
//  ActionManager.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 4/11/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

struct Action {
    let title : String
    let image : UIImage
    let color : UIColor
    let action : (BookData) -> Void
    
    init(title: String, image: UIImage, color: UIColor, action: (BookData) -> Void) {
        self.title = title
        self.image = image
        self.color = color
        self.action = action
    }
    
    init(title: String, imageName: String, color: UIColor, action: (BookData) -> Void) {
        self.init(title: title, image: UIImage(named: imageName)!, color: color, action: action)
    }
    
    func execute(book : BookData) {
        action(book)
    }
}

protocol ActionManager  {
    var viewController : UIViewController! { get set }
    var actions : [Action] { get set }
    var book : BookData! { get set }
}

struct CommonActions  {
    
    static let fileManager = NSFileManager.defaultManager()

    static func downloadAction(url: String, _ viewController : UIViewController) -> Action {
        let ext = NSURL(fileURLWithPath: url).pathExtension!
        
        let documentDirectory = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let filename = NSURL(string: url)!.lastPathComponent!
        let dest = documentDirectory.URLByAppendingPathComponent(filename).path!
        
        if  fileManager.fileExistsAtPath(dest) {
            let title = (ext == "pdf") ? "Read PDF" : "Read EPUB"
            
            return Action(title: title,
                          imageName: "book_\(ext)",
                          color: UIColor.lightBlueColor(),
                          action: { _  in
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                PreviewManager.preview(NSURL(fileURLWithPath: dest), viewController: viewController)
                            }
            })


        } else {
            let title = (ext == "pdf") ? "Download PDF" : "Download EPUB"
            
            return Action(title: title,
                                imageName: "book_\(ext)",
                                color: UIColor.lightBlueColor(),
                                action: { _ in  DownloadManager.startTransfer(url, completionHandler: {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        PreviewManager.preview(NSURL(fileURLWithPath: dest), viewController: viewController)
                                    }
                                })
            })

        }
    }
    
    static func detailsAction(viewController : UIViewController) -> Action {
        return Action(title: "Details",
            imageName: "info",
            color: UIColor.lightBlueColor(),
            action: { book in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nav = storyboard.instantiateViewControllerWithIdentifier("BookDetailsNav") as! UINavigationController
                
                let vc = nav.topViewController as! DetailsViewController
                vc.bookIndex = book.key
                
                viewController.navigationController?.presentViewController(nav, animated: true, completion: {})
        })

    }
    
}


struct DownloadActions : ActionManager {
    var viewController : UIViewController!
    var actions = [Action]()
    var book : BookData!
        
    init(path : String) {
        actions.append(Action(title: Translate.s("Cancel"),
            imageName: "stop",
            color: UIColor.redColor(),
            action: { _ in DownloadManager.cancelTransfer(path)
        }))
    }
}

struct CatalogueActions : ActionManager {
    var viewController : UIViewController!
    var actions = [Action]()
    
    var book : BookData! {
        didSet {
            actions = []
            
            if let url = book.epub_url where url.characters.count > 0 {
                actions.append(CommonActions.downloadAction(url, viewController))
            }

            actions.append(CommonActions.downloadAction(book.download_url, viewController))
            actions.append(CommonActions.detailsAction(viewController))

            actions.append(Action(title: "Add to Favorites",
                imageName: "menu_star",
                color: UIColor.lightBlueColor(),
                action: addToFavorites))

        }
    }
    
    func addToFavorites(book: BookData) {
        let prefs = NSUserDefaults.standardUserDefaults()
        var favorites = prefs.arrayForKey("favorites") as! [String]

        if !favorites.contains(book.key) {
            favorites.append(book.key)
        }
        
        prefs.setObject(favorites, forKey: "favorites")
        prefs.synchronize()

        NSNotificationCenter.defaultCenter().postNotificationName(needReloadFavoritesNotification, object: nil)
    }
}

struct FavoritesActions : ActionManager {
    var viewController : UIViewController!
    var actions = [Action]()
    
    var book : BookData! {
        didSet {
            actions = []
            
            if let url = book.epub_url where url.characters.count > 0 {
                actions.append(CommonActions.downloadAction(url, viewController))
            }
            
            actions.append(CommonActions.downloadAction(book.download_url, viewController))
            actions.append(CommonActions.detailsAction(viewController))
            
            actions.append(Action(title: "Delete",
                imageName: "trash",
                color: UIColor.redColor(),
                action: removeFromFavorites))
        }
    }
    
    func removeFromFavorites(book: BookData) {
        let prefs = NSUserDefaults.standardUserDefaults()
        var favorites = prefs.arrayForKey("favorites") as! [String]
        
        if let index = favorites.indexOf(book.key) {
            favorites.removeAtIndex(index)
        }
        
        prefs.setObject(favorites, forKey: "favorites")
        prefs.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(needReloadFavoritesNotification, object: nil)
        
    }
}


