//
//  CollectionViewCell.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 4/4/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

class CollectionViewCell : UICollectionViewCell, CellInterface {

    @IBOutlet weak var progressbar: UIProgressView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UITextView!
    
    var book : BookData!  {
        didSet {
            title.text = book.title[Translate.language]

            title.textContainer.lineBreakMode = .ByWordWrapping
            title.textContainer.lineFragmentPadding = 0
            title.textContainerInset = UIEdgeInsetsZero
            title.textAlignment = .Center
            title.font = UIFont(name: "Arial", size: 15)
            
            icon!.downloadedFrom(link: book.image, contentMode: .ScaleAspectFit, cell: self)
            progressbar.hidden = true
            
            if let _ = DownloadManager.fileTransferInfo(book.download_url) {
                progressbar.hidden = false
            }
            
            if  let epub_url = book.epub_url,
                let _ = DownloadManager.fileTransferInfo(epub_url) {
                progressbar.hidden = false
            }
            
        }
    }

}
