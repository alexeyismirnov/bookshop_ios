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
        
        if let documentDirectory = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first,
           let filename = NSURL(string: url)!.lastPathComponent,
           let dest = documentDirectory.URLByAppendingPathComponent(filename).path
           where fileManager.fileExistsAtPath(dest) {

            let title = (ext == "pdf") ? "Read PDF" : "Read EPUB"
            
            return Action(title: title,
                          imageName: "book_\(ext)",
                          color: UIColor.lightBlueColor(),
                          action: { _  in  PreviewManager.preview(NSURL(fileURLWithPath: dest), viewController: viewController)
            })


        } else {
            let title = (ext == "pdf") ? "Download PDF" : "Download EPUB"
            
            return Action(title: title,
                                imageName: "book_\(ext)",
                                color: UIColor.lightBlueColor(),
                                action: { _ in  DownloadManager.startTransfer(url, completionHandler: {})
            })

        }
    }
    
}


struct DownloadActions : ActionManager {
    var viewController : UIViewController!
    var actions = [Action]()
    var book : BookData!
        
    init(path : String) {
        actions.append(Action(title: Translate.s("Cancel"),
            imageName: "trash",
            color: UIColor.redColor(),
            action: { _ in DownloadManager.cancelTransfer(path)
        }))
    }
}

struct CatalogueActions : ActionManager {
    let fileManager = NSFileManager.defaultManager()
    var viewController : UIViewController!
    var actions = [Action]()
    
    var book : BookData! {
        didSet {
            
            actions = []
            
            if let url = book.epub_url where url.characters.count > 0 {
                actions.append(CommonActions.downloadAction(url, viewController))
            }

            actions.append(CommonActions.downloadAction(book.download_url, viewController))

            actions.append(Action(title: "Details",
                imageName: "info",
                color: UIColor.lightBlueColor(),
                action: showDetails))

            actions.append(Action(title: "Add to Favorites",
                imageName: "menu_star",
                color: UIColor.lightBlueColor(),
                action: addToFavorites))

        }
    }
    
    
    func showDetails(book: BookData) {
        let nav = viewController.storyboard!.instantiateViewControllerWithIdentifier("BookDetailsNav") as! UINavigationController
        let vc = nav.topViewController as! DetailsViewController
        
        vc.bookIndex = book.key
        
        viewController.navigationController?.presentViewController(nav, animated: true, completion: {})
    }
    
    func addToFavorites(book: BookData) {
        
    }
    
    
}


