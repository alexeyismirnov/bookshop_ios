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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if delegate.model.books.count > 0 {
            collectionView.backgroundView = nil
            return 1
            
        } else {
            let rect = CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
            delegate.emptyFolderLabel.frame = rect
            collectionView.backgroundView = delegate.emptyFolderLabel
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.model.books.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! CollectionViewCell

        if indexPath.row >= delegate.model.books.count {
            return cell
        }
        
        cell.book = delegate.model.books[indexPath.row]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: 210, height: 270)
            
        } else {
            return CGSize(width: 145, height: 190)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsetsMake(5, 10, 5, 10);
    }
    
    @IBAction func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        let loc = gestureRecognizer.location(in: collectionView)
        
        if let path = collectionView?.indexPathForItem(at: loc),
               let cell = collectionView?.cellForItem(at: path) {
            delegate.tap(path, cell)
        }
    }
    
    func reload() {
        collectionView?.reloadData()
    }
    
    func cellForPath(_ path: String) -> UIView? {
        guard let index = delegate.model.books.index(where: { $0.download_url == path || $0.epub_url == path })
            else { return nil }

        return (collectionView?.cellForItem(at: IndexPath(row: index, section: 0)))
    }
    
}
