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
            icon!.downloadedFrom(link: book.image, contentMode: .ScaleAspectFit, cell: self)

            progressbar.hidden = true

            if let _ = DownloadManager.fileTransferInfo(book.download_url) {
                progressbar.hidden = false
            }

            if  let epub_url = book.epub_url,
                let _ = DownloadManager.fileTransferInfo(epub_url) {
                progressbar.hidden = false
            }
            
            let starImage = UIImage(named: "star")?.imageWithRenderingMode(.AlwaysTemplate)
            star.setImage(starImage, forState: .Normal)
            star.tintColor = book.favorite ? UIColor.greenColor() : UIColor.clearColor()

        }
    }
}