//
//  ViewController.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 3/29/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

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

class BooksViewController: UIViewController {
    let prefs = NSUserDefaults.standardUserDefaults()

    var dataSourceId: NSNumber!
    var viewType : ViewType!

    var currentView : MVCInterface!
    var model : BooksModel!
    
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
    
    func tap(index: NSIndexPath) {
        let nav = storyboard!.instantiateViewControllerWithIdentifier("BookDetailsNav") as! UINavigationController
        
        let vc = nav.topViewController as! DetailsViewController
        vc.bookIndex = model.books[index.row].key
        
        navigationController?.presentViewController(nav, animated: true, completion: {})
    }
    
}
