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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.actions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PopoverCell", forIndexPath: indexPath)

        let action = actions.actions[indexPath.row]
        
        cell.textLabel!.textColor = action.color
        cell.textLabel?.text = Translate.s(action.title)
        
        cell.imageView?.tintColor = action.color
        cell.imageView?.image = action.image
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let action = actions.actions[indexPath.row]
        
        action.execute(actions.book)
        
        delegate.dismissPopover()
    }
}