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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.actions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopoverCell", for: indexPath)

        let action = actions.actions[indexPath.row]
        
        cell.textLabel!.textColor = action.color
        cell.textLabel?.text = Translate.s(action.title)
        
        cell.imageView?.tintColor = action.color
        cell.imageView?.image = action.image
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = actions.actions[indexPath.row]
        
        action.execute(actions.book)
        
        delegate.dismissPopover()
    }
}
