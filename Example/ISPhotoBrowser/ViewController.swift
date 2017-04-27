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

    static let urls = ["https://images.unsplash.com/photo-1493064839718-8a4c0259ea9e?dpr=2&auto=compress,format&fit=crop&600&h=800&q=80&cs=tinysrgb",
                "https://images.unsplash.com/photo-1493078640264-28e9ec0ae9ae?dpr=2&auto=compress,format&fit=crop&w=600&h=800&q=80&cs=tinysrgb&crop=&bg=",
                "https://images.unsplash.com/photo-1478028928718-7bfdb1b32095?dpr=2&auto=compress,format&fit=crop&w=600&h=800&q=80&cs=tinysrgb&crop=&bg=",
                "https://images.unsplash.com/photo-1436111805541-f2613bf128ca?dpr=2&auto=compress,format&fit=crop&w=600&h=800&q=80&cs=tinysrgb&crop=&bg=",
                "https://images.unsplash.com/photo-1431629452562-165c8f49fc97?dpr=2&auto=compress,format&fit=crop&w=600&h=800&q=80&cs=tinysrgb&crop=&bg="]
    
    let photos: [ISPhoto] = {
        return urls.map({ (url) -> ISPhoto in
            return ISPhoto(url: URL(string: url)!)
        })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        
//        KingfisherManager.shared.cache.clearMemoryCache()
//        KingfisherManager.shared.cache.clearDiskCache()
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
            photoBrowser.initialPageIndex = indexPath.row
            self.present(photoBrowser, animated: true, completion: nil)
        }

    }
}

