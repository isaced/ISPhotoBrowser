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
    
    /// photo url, if need load image from network
    public var photoURL: URL?
    
    /// init with iamge
    public init(image: UIImage) {
        self.underlyingImage = image
    }
    
    /// init with url
    public init(url: URL) {
        self.photoURL = url
    }

    public func loadUnderlyingImageWithCallback(callback: @escaping (() -> Void)) {
        guard let photoURL = photoURL else {
            callback()
            return
        }

        KingfisherManager.shared.retrieveImage(with: photoURL, options: nil, progressBlock: nil) { [weak self] (image, error, cacheType, url) in
            self?.underlyingImage = image
            callback()
        }
    }
    
    open func unloadUnderlyingImage() {
        underlyingImage = nil
    }
}
