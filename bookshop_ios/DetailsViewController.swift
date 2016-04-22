//
//  DetailsViewController.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 4/5/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import Firebase

class DetailsViewController : UITableViewController {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var book_title: RWLabel!
    @IBOutlet weak var book_descr: RWLabel!
    
    var bookIndex : String!

    let detailsSchema = [("author", "Author"),
                         ("translator", "Translator"),
                         ("language", "Language"),
                         ("pages", "Number of pages"),
                         ("publisher", "Publisher"),
                         ("date_created", "Date added")]
    
    var details = [String:String!]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = Firebase(url: "\(Firebase_url)/details/\(bookIndex)")
        
        ref.observeEventType(.Value, withBlock: { snapshot  in
            let title = snapshot.value["title_\(Translate.language)"] as! String
            let image = snapshot.value["image"] as! String
            let description = snapshot.value["description_\(Translate.language)"] as! String
            
            for (code,_) in self.detailsSchema {
                if code == "author" {
                    self.details[code] = snapshot.value["author_\(Translate.language)"] as! String
                    
                } else {
                    self.details[code] = snapshot.value[code] as! String
                    
                }
            }
            
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                
            self.icon.downloadedFrom(link: image, contentMode: .ScaleAspectFit, cell: cell!)
            self.book_title.text = title
            self.book_descr.text = description
            
            self.tableView.reloadData()
        })
    }
    
    func calculateHeightForCell(cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), CGRectGetHeight(cell.bounds))
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height+1.0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && details.count == 0 {
            return 0
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 1 && details[detailsSchema[indexPath.row].0]!.characters.count == 0) {
            return 0
        }

        let cell : UITableViewCell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        let height = calculateHeightForCell(cell)

        return height
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)

        if indexPath.section != 1 || details.count == 0 {
            return cell
        }

        cell.textLabel!.text = Translate.s(detailsSchema[indexPath.row].1)
        let value = details[detailsSchema[indexPath.row].0]
        
        if (detailsSchema[indexPath.row].0 == "date_created") {
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            var date = dateFormatter.dateFromString(value!)
            
            if date == nil {
                dateFormatter.dateFormat = "yyyy-MM"
                date = dateFormatter.dateFromString(value!)
            }
        
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.timeStyle = .NoStyle
            
            switch Translate.language {
            case "zh_cn":
                formatter.locale = NSLocale(localeIdentifier: "zh_Hans")

            case "zh_hk":
                formatter.locale = NSLocale(localeIdentifier: "zh_Hant")

            default:
                formatter.locale = NSLocale(localeIdentifier: Translate.language)
                
            }
            
            cell.detailTextLabel!.text = formatter.stringFromDate(date!)
            
        } else {
            cell.detailTextLabel!.text = value
        }
        
        return cell
    }

    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
