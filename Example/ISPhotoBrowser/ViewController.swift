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
            
            imageView.layer.cornerRadius = 100.0
            imageView.clipsToBounds = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        

        if let cell = tableView.cellForRow(at: indexPath), let imageView = cell.viewWithTag(101) as? UIImageView {
            let photoBrowser = ISPhotoBrowser(photos: photos, originImage: imageView.image!, animatedFromView: imageView)
            photoBrowser.initialPageIndex = indexPath.row
            self.present(photoBrowser, animated: true, completion: nil)
        }

    }
}

