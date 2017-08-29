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
    
    init(title: String, image: UIImage, color: UIColor, action: @escaping (BookData) -> Void) {
        self.title = title
        self.image = image
        self.color = color
        self.action = action
    }
    
    init(title: String, imageName: String, color: UIColor, action: @escaping (BookData) -> Void) {
        self.init(title: title, image: UIImage(named: imageName)!, color: color, action: action)
    }
    
    func execute(_ book : BookData) {
        action(book)
    }
}

protocol ActionManager  {
    var viewController : UIViewController! { get set }
    var actions : [Action] { get set }
    var book : BookData! { get set }
}

struct CommonActions  {
    
    static let fileManager = FileManager.default

    static func downloadAction(_ url: String, _ viewController : UIViewController) -> Action {
        let ext = URL(fileURLWithPath: url).pathExtension
        
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filename = URL(string: url)!.lastPathComponent
        let dest = documentDirectory.appendingPathComponent(filename).path
        
        if  fileManager.fileExists(atPath: dest) {
            let title = (ext == "pdf") ? "Read PDF" : "Read EPUB"
            
            return Action(title: title,
                          imageName: "book_\(ext)",
                          color: UIColor.lightBlueColor(),
                          action: { _  in
                            
                            DispatchQueue.main.async {
                                PreviewManager.preview(URL(fileURLWithPath: dest), viewController: viewController)
                            }
            })


        } else {
            let title = (ext == "pdf") ? "Download PDF" : "Download EPUB"
            
            return Action(title: title,
                                imageName: "book_\(ext)",
                                color: UIColor.lightBlueColor(),
                                action: { _ in  DownloadManager.startTransfer(url, completionHandler: {
                                    DispatchQueue.main.async {
                                        PreviewManager.preview(URL(fileURLWithPath: dest), viewController: viewController)
                                    }
                                })
            })

        }
    }
    
    static func detailsAction(_ viewController : UIViewController) -> Action {
        return Action(title: "Details",
            imageName: "info",
            color: UIColor.lightBlueColor(),
            action: { book in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nav = storyboard.instantiateViewController(withIdentifier: "BookDetailsNav") as! UINavigationController
                
                let vc = nav.topViewController as! DetailsViewController
                vc.bookIndex = book.key
                
                viewController.navigationController?.present(nav, animated: true, completion: {})
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
            color: UIColor.red,
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
            
            if let url = book.epub_url, url.characters.count > 0 {
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
    
    func addToFavorites(_ book: BookData) {
        let prefs = UserDefaults.standard
        var favorites = prefs.array(forKey: "favorites") as! [String]

        if !favorites.contains(book.key) {
            favorites.append(book.key)
        }
        
        prefs.set(favorites, forKey: "favorites")
        prefs.synchronize()

        NotificationCenter.default.post(name: Notification.Name(rawValue: needReloadFavoritesNotification), object: nil)
    }
}

struct FavoritesActions : ActionManager {
    var viewController : UIViewController!
    var actions = [Action]()
    
    var book : BookData! {
        didSet {
            actions = []
            
            if let url = book.epub_url, url.characters.count > 0 {
                actions.append(CommonActions.downloadAction(url, viewController))
            }
            
            actions.append(CommonActions.downloadAction(book.download_url, viewController))
            actions.append(CommonActions.detailsAction(viewController))
            
            actions.append(Action(title: "Delete",
                imageName: "trash",
                color: UIColor.red,
                action: removeFromFavorites))
        }
    }
    
    func removeFromFavorites(_ book: BookData) {
        let prefs = UserDefaults.standard
        var favorites = prefs.array(forKey: "favorites") as! [String]
        
        if let index = favorites.index(of: book.key) {
            favorites.remove(at: index)
        }
        
        prefs.set(favorites, forKey: "favorites")
        prefs.synchronize()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: needReloadFavoritesNotification), object: nil)
        
    }
}


