//
//  ViewController.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 3/29/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import WYPopoverController

let viewTypeChangedNotification = "viewTypeChanged"

@objc protocol MVCInterface : class {
    var delegate : BooksViewController! { get set }
    @objc func reload()
}

enum ViewType : Int {
    case ListView=0, GridView
}

enum DataSource : Int {
    case Firebase=0, CoreData
}

class BooksViewController: UIViewController, WYPopoverControllerDelegate {
    let prefs = NSUserDefaults.standardUserDefaults()

    var dataSourceId: NSNumber!
    var viewType : ViewType!

    var currentView : MVCInterface!
    var model : BooksModel!
    var popoverController : WYPopoverController?
    
    var viewListButton : UIBarButtonItem!
    var viewGridButton : UIBarButtonItem!
    var optionsButton :  UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewListButton = UIBarButtonItem(image: UIImage(named: "view_list"),
                                         style: .Plain,
                                         target: self,
                                         action: #selector(BooksViewController.switchViewType))
        
        viewGridButton = UIBarButtonItem(image: UIImage(named: "view_grid"),
                                         style: .Plain,
                                         target: self,
                                         action: #selector(BooksViewController.switchViewType))

        optionsButton = UIBarButtonItem(image: UIImage(named: "options"),
                                         style: .Plain,
                                         target: self,
                                         action: #selector(BooksViewController.showOptions))

        createModel()
        createViewController()
        
        model.load() {
            self.currentView.reload()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(BooksViewController.reload),
                                                         name: optionsSavedNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(BooksViewController.createViewController),
                                                         name: viewTypeChangedNotification,
                                                         object: nil)
    }
    
    func createModel() {
        let source = DataSource(rawValue: dataSourceId.integerValue)!
        
        switch (source) {
        case .Firebase:
            model = FirebaseModel()
            
        case .CoreData:
            model = CoreDataModel()
        }
    }
    
    func createViewController() {
        viewType = (prefs.objectForKey("viewType") as! String == "list") ? .ListView : .GridView
        let controllerId = (viewType == .ListView) ? "BooksTableView" : "BooksCollectionView"

        navigationController?.popViewControllerAnimated(false)
        
        let vc = storyboard!.instantiateViewControllerWithIdentifier(controllerId)
        currentView = vc as! MVCInterface
        currentView.delegate = self
        
        vc.navigationItem.leftBarButtonItem = (viewType == .ListView) ? viewGridButton : viewListButton
        vc.navigationItem.rightBarButtonItem = optionsButton
        vc.title = Translate.s("Orthodox Library")
        
        navigationController?.pushViewController(currentView as! UIViewController, animated: false)
    }
    
    func reload() {
        currentView.reload()
    }
    
    func switchViewType() {
        prefs.setObject((viewType == .ListView) ? "grid" : "list", forKey: "viewType")
        prefs.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(viewTypeChangedNotification, object: self)
    }
    
    func showOptions() {
        let nav = storyboard!.instantiateViewControllerWithIdentifier("OptionsNav") as! UINavigationController
        navigationController?.presentViewController(nav, animated: true, completion: {})
    }
    
    func tap(index: NSIndexPath, _ cell : UIView) {
        let popover = storyboard!.instantiateViewControllerWithIdentifier("Popover") as! PopoverViewController
        
        var actions = CatalogueActions()
        actions.viewController = self
        actions.book = model.books[index.row]
        
        popover.actions = actions
        popover.delegate = self
        
        popoverController = WYPopoverController(contentViewController: popover)
        popoverController?.delegate = self
        
        popoverController?.presentPopoverFromRect(cell.bounds,
                                                  inView: cell,
                                                  permittedArrowDirections: WYPopoverArrowDirection.Any,
                                                  animated: true,
                                                  options: WYPopoverAnimationOptions.FadeWithScale)
        
        
    }
    
    func dismissPopover() {
        popoverController?.dismissPopoverAnimated(false, completion: {})
    }
    
    func popoverControllerShouldDismissPopover(_ : WYPopoverController) -> Bool {
        return true
    }
    
    func popoverControllerDidDismissPopover(_ : WYPopoverController) {
        popoverController?.delegate = nil
        popoverController = nil
    }
 
}
