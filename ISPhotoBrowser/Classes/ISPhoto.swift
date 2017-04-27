//
//  ISPhoto.swift
//  Pods
//
//  Created by isaced on 04/26/2017.
//  Copyright (c) 2017 isaced <isaced@163.com> All rights reserved.
//

import Foundation
import Kingfisher

/// This class models a photo/image
/// If you want to handle photos, caching, decompression
/// yourself then you can simply ensure your custom data model
/// conforms to ISPhotoProtocol
open class ISPhoto: ISPhotoProtocol {
    public var underlyingImage: UIImage?
    public var photoURL: URL?
    
    public init(image: UIImage) {
        self.underlyingImage = image
    }
    
    public init(url: URL) {
        self.photoURL = url
    }
    
    public func loadUnderlyingImageAndNotify() {
        assert(Thread.isMainThread, "This method must be called on the main thread.")
        if underlyingImage == nil {
            performLoadUnderlyingImageAndNotify()
        }else{
            loadUnderlyingImageComplete()
        }
    }
    
    public func loadUnderlyingImageWithCallback(callback: @escaping (() -> Void)) {
        guard let photoURL = photoURL else {
            callback()
            return
        }

        KingfisherManager.shared.retrieveImage(with: photoURL, options: nil, progressBlock: nil) { [weak self] (image, error, cacheType, url) in
            self?.underlyingImage = image
            self?.loadUnderlyingImageComplete()
            callback()
        }
    }
    
    public func performLoadUnderlyingImageAndNotify() {
        guard let photoURL = photoURL else { return }
        
        print("retrieveImage: \(photoURL.absoluteString)")
        KingfisherManager.shared.retrieveImage(with: photoURL, options: nil, progressBlock: nil) { [weak self] (image, error, cacheType, url) in
            self?.underlyingImage = image
            self?.loadUnderlyingImageComplete()
            
            print("retrieveImage complate: \(photoURL.absoluteString)")
        }
    }
    
    func loadUnderlyingImageComplete() {
        NotificationCenter.default.post(Notification(name: .ISPhotoLoadingDidEnd))
    }
    
    open func unloadUnderlyingImage() {
        underlyingImage = nil
    }
}
