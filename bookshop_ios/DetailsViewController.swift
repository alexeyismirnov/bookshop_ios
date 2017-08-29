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
    
    var bookIndex = ""

    let detailsSchema = [("author", "Author"),
                         ("translator", "Translator"),
                         ("language", "Language"),
                         ("pages", "Number of pages"),
                         ("publisher", "Publisher"),
                         ("date_created", "Date added")]
    
    var details = [String:String!]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = Database.database().reference().child("details/\(bookIndex)")
        
        ref.observe(.value, with: { snapshot  in
            let dict = snapshot.value as! [String: String]

            let title = dict["title_\(Translate.language)"]
            let image = dict["image"]
            let description = dict["description_\(Translate.language)"]
            
            for (code,_) in self.detailsSchema {
                if code == "author" {
                    self.details[code] = dict["author_\(Translate.language)"]
                    
                } else {
                    self.details[code] = dict[code]
                }
            }
            
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                
            self.icon.downloadedFrom(link: image!, contentMode: .scaleAspectFit, cell: cell!)
            self.book_title.text = title
            self.book_descr.text = description
            
            self.tableView.reloadData()
        })
    }
    
    func calculateHeightForCell(_ cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return size.height+1.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && details.count == 0 {
            return 0
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1 && details[detailsSchema[indexPath.row].0]!.characters.count == 0) {
            return 0
        }

        let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
        let height = calculateHeightForCell(cell)

        return height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if indexPath.section != 1 || details.count == 0 {
            return cell
        }

        cell.textLabel!.text = Translate.s(detailsSchema[indexPath.row].1)
        let value = details[detailsSchema[indexPath.row].0]
        
        if (detailsSchema[indexPath.row].0 == "date_created") {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            var date = dateFormatter.date(from: value!)
            
            if date == nil {
                dateFormatter.dateFormat = "yyyy-MM"
                date = dateFormatter.date(from: value!)
            }
        
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            
            switch Translate.language {
            case "zh_cn":
                formatter.locale = Locale(identifier: "zh_Hans")

            case "zh_hk":
                formatter.locale = Locale(identifier: "zh_Hant")

            default:
                formatter.locale = Locale(identifier: Translate.language)
                
            }
            
            cell.detailTextLabel!.text = formatter.string(from: date!)
            
        } else {
            cell.detailTextLabel!.text = value
        }
        
        return cell
    }

    @IBAction func done(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
