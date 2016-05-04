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

    static func preview(url: NSURL, viewController: UIViewController) {
        
        if showingPreview {
            return

        } else {
            showingPreview = true
        }
        
        if url.pathExtension == "pdf" {
            sharedInstance.viewController = viewController
            sharedInstance.docPreview = UIDocumentInteractionController(URL: url)
            sharedInstance.docPreview!.delegate = sharedInstance
            sharedInstance.docPreview!.presentPreviewAnimated(false)
            
        } else {
            let config = FolioReaderConfig()
            FolioReader.presentReader(parentViewController: viewController, withEpubPath: url.path!, andConfig: config)

        }
    }
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return viewController
    }    
}

