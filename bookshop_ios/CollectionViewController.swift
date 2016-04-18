//
//  CollectionViewController.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 3/29/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

class CollectionViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout, MVCInterface {
    
    var delegate : BooksViewController!

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.model.books.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BookCell", forIndexPath: indexPath) as! CollectionViewCell

        if indexPath.row >= delegate.model.books.count {
            return cell
        }
        
        cell.book = delegate.model.books[indexPath.row]

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return CGSizeMake(210, 270)
            
        } else {
            return CGSizeMake(135, 180)
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {

        return UIEdgeInsetsMake(5, 10, 5, 10);
    }
    
    @IBAction func tap(gestureRecognizer: UITapGestureRecognizer) {
        let loc = gestureRecognizer.locationInView(collectionView)
        
        if let path = collectionView?.indexPathForItemAtPoint(loc),
               cell = collectionView?.cellForItemAtIndexPath(path) {
            delegate.tap(path, cell)
        }
    }
    
    func reload() {
        collectionView?.reloadData()
    }
    
    func cellForPath(path: String) -> UIView? {
        let index = delegate.model.books.indexOf { $0.download_url == path || $0.epub_url == path }
        return (collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: index!, inSection: 0)))
    }
    
}
