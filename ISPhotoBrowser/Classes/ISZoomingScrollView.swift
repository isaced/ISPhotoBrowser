//
//  ISZoomingScrollView.swift
//  Pods
//
//  Created by isaced on 04/26/2017.
//  Copyright (c) 2017 isaced <isaced@163.com> All rights reserved.
//

import UIKit

open class ISZoomingScrollView: UIScrollView {
    var photo: ISPhotoProtocol! {
        didSet {
            photoImageView.image = nil
            if photo != nil && photo.underlyingImage != nil {
                displayImage(complete: true)
            }
            if photo != nil {
                displayImage(complete: false)
            }
        }
    }
    
    fileprivate(set) var photoImageView: UIImageView!
    fileprivate weak var photoBrowser: ISPhotoBrowser?
    
    var indicatorView: UIActivityIndicatorView!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init(frame: CGRect, browser: ISPhotoBrowser) {
        self.init(frame: frame)
        photoBrowser = browser
        setup()
    }
    
    deinit {
        print("ISZoomingScrollView deinit...")
        photoBrowser = nil
    }
    
    func setup() {
        // image view
        photoImageView = UIImageView(frame: frame)
        photoImageView.isUserInteractionEnabled = true
        photoImageView.backgroundColor = .clear
        addSubview(photoImageView)
        
        let photoImageViewDoubleTap = UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageViewDoubleTap(_:)))
        photoImageViewDoubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(photoImageViewDoubleTap)
        
        // indicator
        indicatorView = UIActivityIndicatorView(frame: frame)
        addSubview(indicatorView)
        
        // self
        backgroundColor = .clear
        delegate = self
        decelerationRate = UIScrollViewDecelerationRateFast
        autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin]
    }
    
    // MARK: - override
    
    open override func layoutSubviews() {
        indicatorView.frame = bounds
        
        super.layoutSubviews()
        
        let boundsSize = bounds.size
        var frameToCenter = photoImageView.frame
        
        // horizon
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2)
        } else {
            frameToCenter.origin.x = 0
        }
        // vertical
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2)
        } else {
            frameToCenter.origin.y = 0
        }
        
        // Center
        if !photoImageView.frame.equalTo(frameToCenter) {
            photoImageView.frame = frameToCenter
        }
    }
    
    open func setMaxMinZoomScalesForCurrentBounds() {
        
        // Reset
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        
        // Bail if no image
        guard let _ = photoImageView.image else { return }
        
        // Reset position
        photoImageView.frame = CGRect(x: 0, y: 0, width: photoImageView.frame.size.width, height: photoImageView.frame.size.height)
        
        // Sizes
        let boundsSize = bounds.size
        let imageSize = photoImageView.frame.size
        
        // Calculate Min
        let xScale = boundsSize.width / imageSize.width     // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height   // the scale needed to perfectly fit the image height-wise
        let minScale: CGFloat = min(xScale, yScale)         // use minimum of these to allow the image to become fully visible
        
        // Calculate Max
        var maxScale: CGFloat = 1.0
    
        let scale = max(UIScreen.main.scale, 2.0)
        let deviceScreenWidth = UIScreen.main.bounds.width * scale // width in pixels. scale needs to remove if to use the old algorithm
        let deviceScreenHeight = UIScreen.main.bounds.height * scale // height in pixels. scale needs to remove if to use the old algorithm
        
        if photoImageView.frame.width < deviceScreenWidth {
            // I think that we should to get coefficient between device screen width and image width and assign it to maxScale. I made two mode that we will get the same result for different device orientations.
            if UIApplication.shared.statusBarOrientation.isPortrait {
                maxScale = deviceScreenHeight / photoImageView.frame.width
            } else {
                maxScale = deviceScreenWidth / photoImageView.frame.width
            }
        } else if photoImageView.frame.width > deviceScreenWidth {
            maxScale = 1.0
        } else {
            // here if photoImageView.frame.width == deviceScreenWidth
            maxScale = 2.5
        }
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale
        zoomScale = minScale
        
        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
        // maximum zoom scale to 0.5
        // After changing this value, we still never use more
        /*
         maxScale = maxScale / scale
         if maxScale < minScale {
         maxScale = minScale * 2
         }
         */
        
        // reset position
        photoImageView.frame = CGRect(x: 0, y: 0, width: photoImageView.frame.size.width, height: photoImageView.frame.size.height)
        setNeedsLayout()
    }
    
    // MARK: - image
    open func displayImage(complete flag: Bool) {
        // reset scale
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        contentSize = CGSize.zero
        
        if photo.underlyingImage == nil {
            self.indicatorView.startAnimating()
        }else{
            self.indicatorView.stopAnimating()
        }
        
        photo.loadUnderlyingImageWithCallback {
            
            if let image = self.photo.underlyingImage {
                // image
                self.photoImageView.image = image
                
                var photoImageViewFrame = CGRect.zero
                photoImageViewFrame.origin = CGPoint.zero
                photoImageViewFrame.size = image.size
                
                self.photoImageView.frame = photoImageViewFrame
                
                self.contentSize = photoImageViewFrame.size
                
                self.setMaxMinZoomScalesForCurrentBounds()
                
                self.indicatorView.stopAnimating()
            }else{
                self.indicatorView.startAnimating()
            }
            self.setNeedsLayout()
        }

        setNeedsLayout()
    }
    
    // MARK: - handle tap
    open func handlePhotoImageViewDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let touchPoint = recognizer.location(in: photoImageView)
        
        if let photoBrowser = photoBrowser {
            NSObject.cancelPreviousPerformRequests(withTarget: photoBrowser)
        }
        
        if zoomScale > minimumZoomScale {
            // zoom out
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            // Zoom in to twice the size
            let newZoomScale = ((maximumZoomScale + minimumZoomScale) / 2);
            let xsize = self.bounds.size.width / newZoomScale;
            let ysize = self.bounds.size.height / newZoomScale;
            let zoomRect = CGRect(x: touchPoint.x - xsize/2, y: touchPoint.y - ysize/2, width: xsize, height: ysize)
            zoom(to: zoomRect, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ISZoomingScrollView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
}

private extension ISZoomingScrollView {
    func getViewFramePercent(_ view: UIView, touch: UITouch) -> CGPoint {
        let oneWidthViewPercent = view.bounds.width / 100
        let viewTouchPoint = touch.location(in: view)
        let viewWidthTouch = viewTouchPoint.x
        let viewPercentTouch = viewWidthTouch / oneWidthViewPercent
        
        let photoWidth = photoImageView.bounds.width
        let onePhotoPercent = photoWidth / 100
        let needPoint = viewPercentTouch * onePhotoPercent
        
        var Y: CGFloat!
        
        if viewTouchPoint.y < view.bounds.height / 2 {
            Y = 0
        } else {
            Y = photoImageView.bounds.height
        }
        let allPoint = CGPoint(x: needPoint, y: Y)
        return allPoint
    }
    
    func zoomRectForScrollViewWith(_ scale: CGFloat, touchPoint: CGPoint) -> CGRect {
        let w = frame.size.width / scale
        let h = frame.size.height / scale
        let x = touchPoint.x - (h / max(UIScreen.main.scale, 2.0))
        let y = touchPoint.y - (w / max(UIScreen.main.scale, 2.0))
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
