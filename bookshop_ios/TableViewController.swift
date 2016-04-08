//
//  TableViewController.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 3/29/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

class TableViewController : UITableViewController, MVCInterface {
    
    var delegate : BooksViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.model.books.count
    }
    
    func getCell() -> TableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("BookCell") as? TableViewCell {
            return cell
            
        } else {
            return UITableViewCell(style:.Default, reuseIdentifier: "BookCell") as! TableViewCell
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell()
        
        cell.title!.text = delegate.model.books[indexPath.row].title[Translate.language]
        cell.icon!.downloadedFrom(link: delegate.model.books[indexPath.row].image, contentMode: .ScaleAspectFit, cell: cell)
        
        return cell
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

    @IBAction func tap(gestureRecognizer: UITapGestureRecognizer) {
        let loc = gestureRecognizer.locationInView(tableView)
        
        if let path = tableView?.indexPathForRowAtPoint(loc) {
            delegate.tap(path)
        }
        
    }
    
    func reload() {
        tableView.reloadData()
    }
}