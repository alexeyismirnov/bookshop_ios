//
//  ViewController.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 3/29/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import WYPopoverController

@objc protocol MVCInterface : class {
    var delegate : BooksViewController! { get set }
    @objc func reload()
    @objc func cellForPath(_ path : String) -> UIView?
}

protocol CellInterface : class {
    var progressbar : UIProgressView! { get set }
    var book : BookData! { get set }
}

enum ViewType : Int {
    case listView=0, gridView
}

enum DataSource : Int {
    case firebase=0, coreData
}

class BooksViewController: UIViewController, WYPopoverControllerDelegate {
    let prefs = UserDefaults.standard

    var dataSourceId: NSNumber!
    var viewType : ViewType!

    var currentView : MVCInterface!
    var model : BooksModel!
    var popoverController : WYPopoverController?
    
    var emptyFolderLabel : UILabel!
    var viewListButton : UIBarButtonItem!
    var viewGridButton : UIBarButtonItem!
    var optionsButton :  UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DownloadManager.allViews.append(self)
        
        createButtons()
        createModel()
        createViewController()
        
        reload()
        
        model.load() {
            self.currentView.reload()
        }
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(BooksViewController.reloadFavorites),
                                                         name: NSNotification.Name(rawValue: needReloadFavoritesNotification),
                                                         object: nil)

        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(BooksViewController.reload),
                                                         name: NSNotification.Name(rawValue: optionsSavedNotification),
                                                         object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(BooksViewController.createViewController),
                                                         name: NSNotification.Name(rawValue: viewTypeChangedNotification),
                                                         object: nil)
    }
        
    func createButtons() {
        viewListButton = UIBarButtonItem(image: UIImage(named: "view_list"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(BooksViewController.switchViewType))
        
        viewGridButton = UIBarButtonItem(image: UIImage(named: "view_grid"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(BooksViewController.switchViewType))
        
        optionsButton = UIBarButtonItem(image: UIImage(named: "options"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(BooksViewController.showOptions))

        emptyFolderLabel = UILabel()
        emptyFolderLabel.textColor = UIColor.black
        emptyFolderLabel.numberOfLines = 0
        emptyFolderLabel.textAlignment = .center
        emptyFolderLabel.font = UIFont(name: "Palatino-Italic", size: 20)
    }
    
    func createModel() {
        let source = DataSource(rawValue: dataSourceId.intValue)!
        
        switch (source) {
        case .firebase:
            model = FirebaseModel()
            
        case .coreData:
            model = CoreDataModel()
        }
    }
    
    func createViewController() {
        viewType = (prefs.object(forKey: "viewType") as! String == "list") ? .listView : .gridView
        let controllerId = (viewType == .listView) ? "BooksTableView" : "BooksCollectionView"

        navigationController?.popViewController(animated: false)
        
        let vc = storyboard!.instantiateViewController(withIdentifier: controllerId)
        (vc as! MVCInterface).delegate = self
        currentView = vc as! MVCInterface
        
        vc.navigationItem.leftBarButtonItem = (viewType == .listView) ? viewGridButton : viewListButton
        vc.navigationItem.rightBarButtonItem = optionsButton
        vc.title = Translate.s("Orthodox Library")
        
        navigationController?.pushViewController(currentView as! UIViewController, animated: false)
    }
    
    func reload() {
        currentView.reload()
        
        let source = DataSource(rawValue: dataSourceId.intValue)!
        emptyFolderLabel.text = (source == .firebase) ? Translate.s("Loading...") : Translate.s("No books in this folder")

        (currentView as! UIViewController).title = Translate.s("Orthodox Library")
    }
    
    func reloadFavorites() {
        model.updateFavorites()
        currentView.reload()
    }

    func switchViewType() {
        prefs.set((viewType == .listView) ? "grid" : "list", forKey: "viewType")
        prefs.synchronize()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: viewTypeChangedNotification), object: self)
    }
    
    func showOptions() {
        let nav = storyboard!.instantiateViewController(withIdentifier: "OptionsNav") as! UINavigationController
        navigationController?.present(nav, animated: true, completion: {})
    }
    
    func tap(_ index: IndexPath, _ cell : UIView) {
        
        var actions : ActionManager!
        
        if let fti = DownloadManager.fileTransferInfo((cell as! CellInterface).book.download_url) {
            actions = DownloadActions(path: fti.path)
            
        } else if let epub_url = (cell as! CellInterface).book.epub_url,
                  let fti = DownloadManager.fileTransferInfo(epub_url) {
            
            actions = DownloadActions(path: fti.path)
            
        } else {
            let source = DataSource(rawValue: dataSourceId.intValue)!
            actions = (source == .firebase) ? CatalogueActions() : FavoritesActions()
            actions.viewController = self
        }
        
        actions.book = model.books[index.row]
        
        let height = (actions.actions.count < 3) ? 3 : actions.actions.count
        let popover = storyboard!.instantiateViewController(withIdentifier: "Popover\(height)") as! PopoverViewController
        
        popover.actions = actions
        popover.delegate = self
        
        popoverController = WYPopoverController(contentViewController: popover)
        popoverController?.delegate = self
        
        popoverController?.presentPopover(from: cell.bounds,
                                          in: cell,
                                                  permittedArrowDirections: WYPopoverArrowDirection.any,
                                                  animated: true,
                                                  options: WYPopoverAnimationOptions.fadeWithScale)
        
        
    }
    
    func cellForPath(_ path : String) -> CellInterface? {
        return currentView.cellForPath(path) as? CellInterface
    }
    
    func dismissPopover() {        
        popoverController?.dismissPopover(animated: false)
    }
    
    func popoverControllerShouldDismissPopover(_ : WYPopoverController) -> Bool {
        return true
    }
    
    func popoverControllerDidDismissPopover(_ : WYPopoverController) {
        popoverController?.delegate = nil
        popoverController = nil
    }

}
