//
//  ISPhotoCell.swift
//  Pods
//
//  Created by isaced on 04/26/2017.
//  Copyright (c) 2017 isaced <isaced@163.com> All rights reserved.
//

import UIKit

class ISPhotoCell: UICollectionViewCell {

    var zoomingScrollView: ISZoomingScrollView!
    
    var photo: ISPhotoProtocol? {
        didSet{
            zoomingScrollView.photo = photo
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
        
        print("ISPhotoCell init...")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        zoomingScrollView.layoutSubviews()
    }
    
    func config() {
        var frame = self.bounds
        frame.size.width = frame.size.width - CGFloat(ISPhotoCellMargin)
        zoomingScrollView = ISZoomingScrollView(frame: frame)
        addSubview(zoomingScrollView)
    }
}
