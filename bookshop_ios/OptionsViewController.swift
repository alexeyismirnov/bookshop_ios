//
//  OptionsViewController.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 4/8/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

class OptionsViewController : UITableViewController {

    let prefs = UserDefaults.standard
    var firstRun = false

    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let index = languages.index(of: prefs.string(forKey: "language")!)!
        
        let cell = self.tableView(tableView, cellForRowAt: IndexPath(row: index, section: 0)) as UITableViewCell
        cell.accessoryType = .checkmark
        
        button.setTitle(Translate.s("Done"), for: UIControlState())
        button.layer.borderColor = UIColor.lightBlueColor().cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 10
        button.setTitleColor(UIColor.lightBlueColor(), for: UIControlState())
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            return;
        }

        var cell: UITableViewCell

        for row in 0...3 {
            cell = self.tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0)) as UITableViewCell
            cell.accessoryType = .none
        }
        
        cell = self.tableView(tableView, cellForRowAt: indexPath) as UITableViewCell
        cell.accessoryType = .checkmark
        
        let row = indexPath.row

        Translate.language = languages[row]
        prefs.set(languages[row], forKey: "language")
        prefs.synchronize()
        
        button.setTitle(Translate.s("Done"), for: UIControlState())
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Translate.s("Language")
            
        } else if section == 2  {
            return Translate.s("(C) 2016 Brotherhood of Sts Apostoles Peter and Paul, Hong Kong.")
        }
        
        return nil
    }
    
    @IBAction func done(_ sender: AnyObject) {
        if firstRun {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MainView")
            UIApplication.shared.keyWindow?.rootViewController = controller;

        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: optionsSavedNotification), object: nil)
            dismiss(animated: true, completion: nil)
            
        }
    }
}
