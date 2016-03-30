//
//  ViewController.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 3/29/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

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
    var dataSourceId: NSNumber!
    var viewType : ViewType!
    
    var currentView : MVCInterface!
    var model : BooksModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createModel()
        createViewController()
        
        model.load() {
            self.currentView.reload()
        }
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
        let prefs = NSUserDefaults.standardUserDefaults()

        viewType = (prefs.objectForKey("viewType") as! String == "list") ? .ListView : .GridView
        let controllerId = (viewType == .ListView) ? "BooksTableView" : "BooksCollectionView"

        /*
        if let _ = currentView {
            navigationController?.popViewControllerAnimated(false)
        }
*/
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        currentView = storyboard.instantiateViewControllerWithIdentifier(controllerId) as! MVCInterface
        currentView.delegate = self
        
        let fakeButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: Selector(""))
        (currentView as! UIViewController).navigationItem.leftBarButtonItem = fakeButton

        navigationController?.pushViewController(currentView as! UIViewController, animated: false)
    }
    
}
