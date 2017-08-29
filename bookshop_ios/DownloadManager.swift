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
    var task : URLSessionTask!
    var progress : Float
    var completionHandler : () -> Void
}

class DownloadManager : NSObject, URLSessionDownloadDelegate, URLSessionDataDelegate {
    
    static let sharedInstance = DownloadManager()
    static var allViews = [BooksViewController]()
    static var currentTransfers = [Int : FileTransferInfo]()
    
    var downloadSessionConfig : URLSessionConfiguration!
    var downloadSession : Foundation.URLSession!
    
    override init() {
        super.init()
        downloadSessionConfig = URLSessionConfiguration.default
        downloadSession = Foundation.URLSession(configuration: downloadSessionConfig, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    func createTask(_ path: String) -> URLSessionTask {

        return downloadSession.dataTask(with: URL(string: path)!)
    }
    
    static func startTransfer(_ path: String, completionHandler: @escaping () -> Void) {
        guard let reachability =  Reachability.forInternetConnection() else { return }
        
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
                cell.progressbar.isHidden = false
                cell.progressbar.progress = 0
            }
        }
        
        task.resume()
    }
    
    static func fileTransferInfo(_ path: String) -> FileTransferInfo? {
        let transfer = currentTransfers.filter { $0.1.path == path }
        return transfer.count > 0 ? transfer[0].1 : nil
    }
    
    static func cancelTransfer(_ path: String) {
        guard let fti = fileTransferInfo(path) else { return }
        
        fti.task.cancel()
        currentTransfers.removeValue(forKey: fti.task.taskIdentifier)
        
        for vc in DownloadManager.allViews {
            if let cell = vc.cellForPath(path) {
                cell.progressbar.isHidden = true
            }
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.becomeDownload)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        downloadTask.resume()
    }
 
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

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
 
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)

        guard let fti = DownloadManager.currentTransfers[downloadTask.taskIdentifier],
              let url = URL(string: fti.path),
              let documentDirectory:URL = urls.first else { return }

        let filename = url.lastPathComponent
        let dest = documentDirectory.appendingPathComponent(filename)
        let fileData = try? Data(contentsOf: location)
        
        do {
            try fileData?.write(to: dest, options: .noFileProtection)
            try (dest as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        for vc in DownloadManager.allViews {
            if let cell = vc.cellForPath(fti.path) {
                cell.progressbar.isHidden = true
            }
        }

        DownloadManager.currentTransfers.removeValue(forKey: fti.task.taskIdentifier)
        
        Environment.showNotification("Donwload complete", subtitle: Translate.s("Download complete"), isError: false)
        fti.completionHandler()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let e = error {
            Environment.showNotification("Error", subtitle: Translate.s(e.localizedDescription), isError: true)
        }
    }
}
