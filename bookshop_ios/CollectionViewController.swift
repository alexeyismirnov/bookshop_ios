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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.model.books.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BookCell", forIndexPath: indexPath) as! CollectionViewCell

        if indexPath.row >= delegate.model.books.count {
            return cell
        }
        
        cell.title!.text = delegate.model.books[indexPath.row].title[Translate.language]
        cell.icon!.downloadedFrom(link: delegate.model.books[indexPath.row].image, contentMode: .ScaleAspectFit, cell: cell)

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

        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
    
    @IBAction func tap(gestureRecognizer: UITapGestureRecognizer) {
        let loc = gestureRecognizer.locationInView(collectionView)
        
        if let path = collectionView?.indexPathForItemAtPoint(loc) {
            delegate.tap(path)
        }
    }
    
    func reload() {
        collectionView?.reloadData()
    }
}
