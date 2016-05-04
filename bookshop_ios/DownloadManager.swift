//
//  File.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 4/13/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import Reachability

struct FileTransferInfo {
    var path : String!
    var task : NSURLSessionTask!
    var progress : Float
    var completionHandler : () -> Void
}

class DownloadManager : NSObject, NSURLSessionDownloadDelegate, NSURLSessionDataDelegate {
    
    static let sharedInstance = DownloadManager()
    static var allViews = [BooksViewController]()
    static var currentTransfers = [Int : FileTransferInfo]()
    
    var downloadSessionConfig : NSURLSessionConfiguration!
    var downloadSession : NSURLSession!
    
    override init() {
        super.init()
        downloadSessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        downloadSession = NSURLSession(configuration: downloadSessionConfig, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    func createTask(path: String) -> NSURLSessionTask {

        return downloadSession.dataTaskWithURL(NSURL(string: path)!)
    }
    
    static func startTransfer(path: String, completionHandler: () -> Void) {
        guard let reachability =  Reachability.reachabilityForInternetConnection() else { return }
        
        if reachability.currentReachabilityStatus() == .NotReachable {
            Environment.showNotification("Error", subtitle: Translate.s("Cannot connect to Internet"), isError: true)
            return
        }
 
        if let _ = DownloadManager.fileTransferInfo(path) {
            return
        }
        
        let task = sharedInstance.createTask(path)
        
        let fti = FileTransferInfo(path: path,
                                   task: task,
                                   progress: 0,
                                   completionHandler: completionHandler)
        
        currentTransfers[task.taskIdentifier] = fti
        
        for vc in DownloadManager.allViews {
            if let cell = vc.cellForPath(path) {
                cell.progressbar.hidden = false
                cell.progressbar.progress = 0
            }
        }
        
        task.resume()
    }
    
    static func fileTransferInfo(path: String) -> FileTransferInfo? {
        let transfer = currentTransfers.filter { $0.1.path == path }
        return transfer.count > 0 ? transfer[0].1 : nil
    }
    
    static func cancelTransfer(path: String) {
        guard let fti = fileTransferInfo(path) else { return }
        
        fti.task.cancel()
        currentTransfers.removeValueForKey(fti.task.taskIdentifier)
        
        for vc in DownloadManager.allViews {
            if let cell = vc.cellForPath(path) {
                cell.progressbar.hidden = true
            }
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        completionHandler(.BecomeDownload)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didBecomeDownloadTask downloadTask: NSURLSessionDownloadTask) {
        downloadTask.resume()
    }
 
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        if totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown {
            print("Unknown transfer size")
            return
        }
        
        let progress  = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        for vc in DownloadManager.allViews {
            if let fti = DownloadManager.currentTransfers[downloadTask.taskIdentifier],
               let cell = vc.cellForPath(fti.path) {
                cell.progressbar.progress = progress
            }
        }
            
        DownloadManager.currentTransfers[downloadTask.taskIdentifier]?.progress = progress
 
    }
 
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)

        guard let fti = DownloadManager.currentTransfers[downloadTask.taskIdentifier],
              let url = NSURL(string: fti.path),
              let filename = url.lastPathComponent,
              let documentDirectory:NSURL = urls.first else { return }

        let dest = documentDirectory.URLByAppendingPathComponent(filename)
        let fileData = NSData(contentsOfURL: location)
        
        do {
            try? dest.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
            
            try fileData?.writeToURL(dest, options: .DataWritingFileProtectionNone)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        for vc in DownloadManager.allViews {
            if let cell = vc.cellForPath(fti.path) {
                cell.progressbar.hidden = true
            }
        }

        DownloadManager.currentTransfers.removeValueForKey(fti.task.taskIdentifier)
        
        Environment.showNotification("Donwload complete", subtitle: Translate.s("Download complete"), isError: false)
        fti.completionHandler()
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let e = error {
            Environment.showNotification("Error", subtitle: Translate.s(e.localizedDescription), isError: true)
        }
    }
}
