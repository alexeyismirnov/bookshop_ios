//
//  TableViewCell.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 4/4/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

class TableViewCell : UITableViewCell, CellInterface {
    
    @IBOutlet weak var progressbar: UIProgressView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: RWLabel!
    @IBOutlet weak var star: UIButton!
    
    var book : BookData! {
        didSet {
            title!.text = book.title[Translate.language]
            icon!.downloadedFrom(link: book.image, contentMode: .scaleAspectFit, cell: self)

            progressbar.isHidden = true

            if let fti = DownloadManager.fileTransferInfo(book.download_url) {
                progressbar.isHidden = false
                progressbar.progress = fti.progress
            }

            if  let epub_url = book.epub_url,
                let fti = DownloadManager.fileTransferInfo(epub_url) {
                progressbar.isHidden = false
                progressbar.progress = fti.progress
            }
            
            let starImage = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
            star.setImage(starImage, for: UIControlState())
            star.tintColor = book.favorite ? UIColor.green : UIColor.clear

        }
    }
}
