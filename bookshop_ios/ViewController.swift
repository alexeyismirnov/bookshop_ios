//
//  ViewController.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 3/29/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

let viewTypeChangedNotification = "viewTypeChanged"

protocol MVCInterface : class {
    var delegate : BooksViewController! { get set }
    func reload()
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

        createModel()
        createViewController()
        
        model.load() {
            self.currentView.reload()
        }
        
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
        
        currentView = storyboard!.instantiateViewControllerWithIdentifier(controllerId) as! MVCInterface
        currentView.delegate = self
        
        (currentView as! UIViewController).navigationItem.leftBarButtonItem = (viewType == .ListView) ? viewGridButton : viewListButton

        navigationController?.pushViewController(currentView as! UIViewController, animated: false)
    }
    
    func switchViewType() {
        prefs.setObject((viewType == .ListView) ? "grid" : "list", forKey: "viewType")
        prefs.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(viewTypeChangedNotification, object: self)
    }
    
}
