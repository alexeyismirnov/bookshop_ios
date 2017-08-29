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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if delegate.model.books.count > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            return 1
            
        } else {
            let rect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
            delegate.emptyFolderLabel.frame = rect
            tableView.backgroundView = delegate.emptyFolderLabel
            tableView.separatorStyle = .none
            return 0
        }
    }
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.model.books.count
    }
    
    func getCell() -> TableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as? TableViewCell {
            return cell
            
        } else {
            return UITableViewCell(style:.default, reuseIdentifier: "BookCell") as! TableViewCell
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell()
        cell.book = delegate.model.books[indexPath.row]

        return cell
    }
    
    func calculateHeightForCell(_ cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return size.height+1.0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {        
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
        return calculateHeightForCell(cell)
    }

    @IBAction func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        let loc = gestureRecognizer.location(in: tableView)
        
        if let path = tableView?.indexPathForRow(at: loc),
               let cell = tableView.cellForRow(at: path) {
            
            delegate.tap(path, cell)
        }
        
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    func cellForPath(_ path: String) -> UIView? {
        guard let index = delegate.model.books.index(where: { $0.download_url == path || $0.epub_url == path }) else { return nil }
        return tableView.cellForRow(at: IndexPath(row: index, section: 0))
    }
}

