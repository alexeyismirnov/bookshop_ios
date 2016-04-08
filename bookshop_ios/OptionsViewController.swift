//
//  OptionsViewController.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 4/8/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

class OptionsViewController : UITableViewController {

    let prefs = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Translate.s("Options")
        
        let index = languages.indexOf(prefs.stringForKey("language")!)!
        
        let cell = self.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: index, inSection: 0)) as UITableViewCell
        cell.accessoryType = .Checkmark

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section != 0 {
            return;
        }

        var cell: UITableViewCell

        for row in 0...3 {
            cell = self.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: row, inSection: 0)) as UITableViewCell
            cell.accessoryType = .None
        }
        
        cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        cell.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Translate.s("Language")
        } else {
            return Translate.s("(C) 2016 Brotherhood of Sts Apostoles Peter and Paul, Hong Kong.")
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        for row in 0...3 {
            let cell = self.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: row, inSection: 0)) as UITableViewCell

            if cell.accessoryType == .Checkmark {
                Translate.language = languages[row]
                prefs.setObject(languages[row], forKey: "language")
                prefs.synchronize()
            }
        }

        NSNotificationCenter.defaultCenter().postNotificationName(optionsSavedNotification, object: nil)

        dismissViewControllerAnimated(true, completion: nil)
    }
}
