//
//  PopoverViewController.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 4/11/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

class PopoverViewController : UITableViewController {
    var actions : ActionManager!
    var delegate : BooksViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSizeMake(200, 150)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.actions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PopoverCell", forIndexPath: indexPath)

        cell.textLabel?.text = actions.actions[indexPath.row].title
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let action = actions.actions[indexPath.row]
        
        action.execute(actions.book)
        
        delegate.dismissPopover()
    }
}