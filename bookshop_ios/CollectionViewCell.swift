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
            
            let starImage = UIImage(named: "star")!.imageWithRenderingMode(.AlwaysTemplate)
            let color = book.favorite ? UIColor.greenColor() : UIColor.clearColor()
            
            let attachment = NSTextAttachment()
            attachment.image = starImage.resize(CGSizeMake(15, 15), color: color)
            
            let attachmentString = NSAttributedString(attachment: attachment)
            let str = NSMutableAttributedString()
            
            if color != UIColor.clearColor() {
                str.appendAttributedString(attachmentString)
            }
            
            str.appendAttributedString(NSAttributedString(string: book.title[Translate.language]!))
            
            title.attributedText = str

            title.textContainer.lineBreakMode = .ByWordWrapping
            title.textContainer.lineFragmentPadding = 0
            title.textContainerInset = UIEdgeInsetsZero
            title.textAlignment = .Center
            title.font = UIFont(name: "Arial", size: 15)
            
            icon!.downloadedFrom(link: book.image, contentMode: .ScaleAspectFit, cell: self)
            progressbar.hidden = true
            
            if let fti = DownloadManager.fileTransferInfo(book.download_url) {
                progressbar.hidden = false
                progressbar.progress = fti.progress
            }
            
            if  let epub_url = book.epub_url,
                let fti = DownloadManager.fileTransferInfo(epub_url) {
                progressbar.hidden = false
                progressbar.progress = fti.progress
            }
            
        }
    }

}
