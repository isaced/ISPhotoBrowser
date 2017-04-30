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
    
    func config() {
        var zoomingScrollViewFrame = self.bounds
        zoomingScrollViewFrame.size.width = zoomingScrollViewFrame.size.width - CGFloat(ISPhotoCellMargin)
        zoomingScrollView = ISZoomingScrollView(frame: zoomingScrollViewFrame)
        zoomingScrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(zoomingScrollView)
        self.addConstraints([NSLayoutConstraint(item: zoomingScrollView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: zoomingScrollView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: zoomingScrollView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: CGFloat(-ISPhotoCellMargin)),
                             NSLayoutConstraint(item: zoomingScrollView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)])
    }
    
    func updateZoomScalesForCurrentBounds() {
        zoomingScrollView.setMaxMinZoomScalesForCurrentBounds()
    }
}
