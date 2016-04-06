//
//  DetailsViewController.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 4/5/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

class DetailsViewController : UITableViewController {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var book_title: RWLabel!
    
    var bookIndex : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = Firebase(url: "\(Firebase_url)/details/\(bookIndex)")
        
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot  in

            let item = BookData(snapshot: snapshot)
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                
            self.icon.downloadedFrom(link: item.image, contentMode: .ScaleAspectFit, cell: cell!)
            self.book_title.text = item.title
        })
    }
    
    func calculateHeightForCell(cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), CGRectGetHeight(cell.bounds))
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height+1.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        return calculateHeightForCell(cell)
    }

    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
