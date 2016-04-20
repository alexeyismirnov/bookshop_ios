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
    var firstRun = false

    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let index = languages.indexOf(prefs.stringForKey("language")!)!
        
        let cell = self.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: index, inSection: 0)) as UITableViewCell
        cell.accessoryType = .Checkmark
        
        button.setTitle(Translate.s("Done"), forState: .Normal)
        button.layer.borderColor = UIColor.lightBlueColor().CGColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 10
        button.setTitleColor(UIColor.lightBlueColor(), forState: .Normal)
        
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
        
        let row = indexPath.row

        Translate.language = languages[row]
        prefs.setObject(languages[row], forKey: "language")
        prefs.synchronize()
        
        button.setTitle(Translate.s("Done"), forState: .Normal)
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Translate.s("Language")
            
        } else if section == 2  {
            return Translate.s("(C) 2016 Brotherhood of Sts Apostoles Peter and Paul, Hong Kong.")
        }
        
        return nil
    }
    
    @IBAction func done(sender: AnyObject) {
        if firstRun {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("MainView")
            UIApplication.sharedApplication().keyWindow?.rootViewController = controller;

        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(optionsSavedNotification, object: nil)
            dismissViewControllerAnimated(true, completion: nil)
            
        }
    }
}
