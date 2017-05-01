//
//  ViewController.swift
//  ISPhotoBrowser
//
//  Created by isaced on 04/26/2017.
//  Copyright (c) 2017 isaced <isaced@163.com> All rights reserved.
//

import UIKit
import Kingfisher
import ISPhotoBrowser

class ViewController: UITableViewController {

    var photos: [ISPhoto]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200

//        KingfisherManager.shared.cache.clearMemoryCache()
//        KingfisherManager.shared.cache.clearDiskCache()
        
        let urls = ["https://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg",
                    "https://farm4.static.flickr.com/3629/3339128908_7aecabc34b_b.jpg",
                    "https://farm4.static.flickr.com/3364/3338617424_7ff836d55f_b.jpg",
                    "https://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_b.jpg"]
        let photos: [ISPhoto] = urls.map({ (url) -> ISPhoto in
            return ISPhoto(url: URL(string: url)!)
        })
        self.photos = photos
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let imageView = cell.viewWithTag(101) as? UIImageView {
            imageView.kf.setImage(with: photos[indexPath.row].photoURL)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        

        if let cell = tableView.cellForRow(at: indexPath), let imageView = cell.viewWithTag(101) as? UIImageView {
            let photoBrowser = ISPhotoBrowser(photos: photos, originImage: imageView.image!, animatedFromView: imageView)
            
            photoBrowser.delegate = self
            
            // === Customize ===
            
            // initial page
            photoBrowser.initialPageIndex = indexPath.row
            
            // background color
            photoBrowser.backgroundColor = .gray
            
            // single tap dismiss
            photoBrowser.enableSingleTapDismiss = true
            
            // === Customize ===
            
            self.present(photoBrowser, animated: true, completion: nil)
        }

    }
}

extension ViewController: ISPhotoBrowserDelegate {
    func didShowPhotoAtIndex(_ index: Int) {
        print("ISPhotoBrowser didShowPhotoAtIndex:  \(index)")
        
        tableView.visibleCells.forEach({$0.isHidden = false})
        tableView.cellForRow(at: IndexPath(row: index, section: 0))?.isHidden = true
    }
    
    func willDismissAtPageIndex(_ index: Int) {
        print("ISPhotoBrowser willDismissAtPageIndex:  \(index)")
    }
    
    func didDismissAtPageIndex(_ index: Int) {
        print("ISPhotoBrowser didDismissAtPageIndex:  \(index)")
        
        tableView.cellForRow(at: IndexPath(row: index, section: 0))?.isHidden = false
    }
    
    func didScrollToIndex(_ index: Int) {
        print("ISPhotoBrowser didScrollToIndex:  \(index)")
    }
    
    func viewForPhoto(_ browser: ISPhotoBrowser, index: Int) -> UIView? {
        return tableView.cellForRow(at: IndexPath(row: index, section: 0))?.viewWithTag(101)
    }
}
