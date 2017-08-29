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
            
            let starImage = UIImage(named: "star")!.withRenderingMode(.alwaysTemplate)
            let color = book.favorite ? UIColor.green : UIColor.clear
            
            let attachment = NSTextAttachment()
            attachment.image = starImage.resize(CGSize(width: 15, height: 15), color: color)
            
            let attachmentString = NSAttributedString(attachment: attachment)
            let str = NSMutableAttributedString()
            
            if color != UIColor.clear {
                str.append(attachmentString)
            }
            
            str.append(NSAttributedString(string: book.title[Translate.language]!))
            
            title.attributedText = str

            title.textContainer.lineBreakMode = .byWordWrapping
            title.textContainer.lineFragmentPadding = 0
            title.textContainerInset = UIEdgeInsets.zero
            title.textAlignment = .center
            title.font = UIFont(name: "Arial", size: 15)
            
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
            
        }
    }

}
