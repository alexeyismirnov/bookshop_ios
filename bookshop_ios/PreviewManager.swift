//
//  PreviewManager.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 4/13/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit


class PreviewManager : NSObject, UIDocumentInteractionControllerDelegate {
    static let sharedInstance = PreviewManager()
    var viewController : UIViewController!
    var docPreview : UIDocumentInteractionController!

    static func preview(url: NSURL, viewController: UIViewController) {
        sharedInstance.viewController = viewController
        sharedInstance.docPreview = UIDocumentInteractionController(URL: url)
        sharedInstance.docPreview.delegate = sharedInstance
        sharedInstance.docPreview.presentPreviewAnimated(true)
    }
    
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return viewController
    }
}

