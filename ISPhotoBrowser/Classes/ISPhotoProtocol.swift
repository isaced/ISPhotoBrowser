//
//  ISPhotoProtocol.swift
//  Pods
//
//  Created by isaced on 04/26/2017.
//  Copyright (c) 2017 isaced <isaced@163.com> All rights reserved.
//

import Foundation

/// If you wish to use your own data models for photo then they must conform
/// to this protocol. See instructions for details on each method.
/// Otherwise you can use the ISPhoto object or subclass it yourself to
/// store more information per photo.
///
/// You can see the ISPhoto class for an example implementation of this protocol
///
public protocol ISPhotoProtocol {
    
    /// Return underlying UIImage to be displayed
    /// Return nil if the image is not immediately available (loaded into memory, preferably
    /// already decompressed) and needs to be loaded from a source (cache, file, web, etc)
    /// IMPORTANT: You should *NOT* use this method to initiate
    /// fetching of images from any external of source. That should be handled
    /// in -loadUnderlyingImageAndNotify: which may be called by the photo browser if this
    /// methods returns nil.
    var underlyingImage: UIImage? { get }
    
    /// Called when the browser has determined the underlying images is not
    /// already loaded into memory but needs it.
    func loadUnderlyingImageAndNotify()
    
    func loadUnderlyingImageWithCallback(callback: @escaping (()->Void))
    
    /// Fetch the image data from a source and notify when complete.
    /// You must load the image asyncronously (and decompress it for better performance).
    /// It is recommended that you use Kingfisher to perform the decompression.
    /// See ISPhoto object for an example implementation.
    /// When the underlying UIImage is loaded (or failed to load) you should post the following
    /// notification:
    ///  NotificationCenter.default.post(Notification(name: .ISPhotoLoadingDidEnd))
    func performLoadUnderlyingImageAndNotify()
    
    /// This is called when the photo browser has determined the photo data
    /// is no longer needed or there are low memory conditions
    /// You should release any underlying (possibly large and decompressed) image data
    /// as long as the image can be re-loaded (from cache, file, or URL)
    func unloadUnderlyingImage()
}
