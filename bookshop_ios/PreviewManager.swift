//
//  PreviewManager.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 4/13/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import FolioReaderKit

class PreviewManager : NSObject, UIDocumentInteractionControllerDelegate {
    static let sharedInstance = PreviewManager()
    static var showingPreview = false
    
    var viewController : UIViewController!
    var docPreview : UIDocumentInteractionController?

    static func preview(_ url: URL, viewController: UIViewController) {
        
        if showingPreview {
            return

        } else {
            showingPreview = true
        }
        
        if url.pathExtension == "pdf" {
            sharedInstance.viewController = viewController
            sharedInstance.docPreview = UIDocumentInteractionController(url: url)
            sharedInstance.docPreview!.delegate = sharedInstance
            sharedInstance.docPreview!.presentPreview(animated: false)
            
        } else {
            let config = FolioReaderConfig()
            let folioReader = FolioReader()

            folioReader.presentReader(parentViewController: viewController, withEpubPath: url.path, andConfig: config)

        }
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return viewController
    }    
}

