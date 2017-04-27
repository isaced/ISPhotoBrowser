//
//  ISAnimator.swift
//  Pods
//
//  Created by isaced on 04/26/2017.
//  Copyright (c) 2017 isaced <isaced@163.com> All rights reserved.
//

import UIKit

@objc public protocol ISPhotoBrowserAnimatorDelegate {
    func willPresent(_ browser: ISPhotoBrowser)
    func willDismiss(_ browser: ISPhotoBrowser)
}

class ISAnimator: NSObject, ISPhotoBrowserAnimatorDelegate {
    var resizableImageView: UIImageView?
    
    var senderOriginImage: UIImage!
    var senderViewOriginalFrame: CGRect = .zero
    var senderViewForAnimation: UIView?
    
    var finalImageViewFrame: CGRect = .zero
    
    var bounceAnimation: Bool = false
    var animationDuration: TimeInterval = 0.5
    var animationDamping: CGFloat = 0.8
    
    func willPresent(_ browser: ISPhotoBrowser) {
        guard let appWindow = UIApplication.shared.delegate?.window else {
            return
        }
        guard let window = appWindow else {
            return
        }
        guard let sender = browser.delegate?.viewForPhoto(browser, index: browser.initialPageIndex) ?? senderViewForAnimation else {
            presentAnimation(browser)
            return
        }
        
//        let photo = browser.photoAtIndex(browser.currentPageIndex)
        let imageFromView = (senderOriginImage ?? browser.getImageFromView(sender)).rotateImageByOrientation()
        let imageRatio = imageFromView.size.width / imageFromView.size.height
        
        senderViewOriginalFrame = calcOriginFrame(sender)
        finalImageViewFrame = calcFinalFrame(imageRatio)
        
        resizableImageView = UIImageView(image: imageFromView)
        resizableImageView!.frame = senderViewOriginalFrame
        resizableImageView!.clipsToBounds = true
        if let conentMode = senderViewForAnimation?.contentMode {
            resizableImageView!.contentMode = conentMode //photo.contentMode
        }
        
//        if sender.layer.cornerRadius != 0 {
//            let duration = (animationDuration * Double(animationDamping))
//            resizableImageView!.layer.masksToBounds = true
//            resizableImageView!.addCornerRadiusAnimation(sender.layer.cornerRadius, to: 0, duration: duration)
//        }
        window.addSubview(resizableImageView!)
        
        presentAnimation(browser)
    }
    
    func willDismiss(_ browser: ISPhotoBrowser) {
        guard let sender = browser.delegate?.viewForPhoto(browser, index: browser.currentPageIndex),
            let image = browser.photoAtIndex(browser.currentPageIndex).underlyingImage,
            let scrollView = browser.pageDisplayedAtIndex(browser.currentPageIndex) else {
            
                senderViewForAnimation?.isHidden = false
                browser.dismissPhotoBrowser(animated: false)
                return
        }
        
        senderViewForAnimation = sender
        browser.view.isHidden = true
        browser.backgroundView.isHidden = false
        browser.backgroundView.alpha = 1
        
        senderViewOriginalFrame = calcOriginFrame(sender)
        
//        let photo = browser.photoAtIndex(browser.currentPageIndex)
        let contentOffset = scrollView.contentOffset
        let scrollFrame = scrollView.photoImageView.frame
        let offsetY = scrollView.center.y - (scrollView.bounds.height/2)
        let frame = CGRect(x: scrollFrame.origin.x - contentOffset.x,
                           y: scrollFrame.origin.y + contentOffset.y + offsetY,
                           width: scrollFrame.width,
                           height: scrollFrame.height)
        
        //        resizableImageView.image = scrollView.photo?.underlyingImage?.rotateImageByOrientation()
        resizableImageView!.image = image.rotateImageByOrientation()
        resizableImageView!.frame = frame
        resizableImageView!.alpha = 1.0
        resizableImageView!.clipsToBounds = true
//        resizableImageView!.contentMode = photo.contentMode
//        if let view = senderViewForAnimation , view.layer.cornerRadius != 0 {
//            let duration = (animationDuration * Double(animationDamping))
//            resizableImageView!.layer.masksToBounds = true
//            resizableImageView!.addCornerRadiusAnimation(0, to: view.layer.cornerRadius, duration: duration)
//        }
        
        dismissAnimation(browser)
    }
}

private extension ISAnimator {
    func calcOriginFrame(_ sender: UIView) -> CGRect {
        if let senderViewOriginalFrameTemp = sender.superview?.convert(sender.frame, to:nil) {
            return senderViewOriginalFrameTemp
        } else if let senderViewOriginalFrameTemp = sender.layer.superlayer?.convert(sender.frame, to: nil) {
            return senderViewOriginalFrameTemp
        } else {
            return .zero
        }
    }
    
    func calcFinalFrame(_ imageRatio: CGFloat) -> CGRect {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let screenRatio = screenWidth / screenHeight
        
        if screenRatio < imageRatio {
            let width = screenWidth
            let height = width / imageRatio
            let yOffset = (screenHeight - height) / 2
            return CGRect(x: 0, y: yOffset, width: width, height: height)
        } else {
            let height = screenHeight
            let width = height * imageRatio
            let xOffset = (screenWidth - width) / 2
            return CGRect(x: xOffset, y: 0, width: width, height: height)
        }
    }
}

private extension ISAnimator {
    func presentAnimation(_ browser: ISPhotoBrowser, completion: ((Void) -> Void)? = nil) {
        browser.backgroundView.alpha = 0.0
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: animationDamping, initialSpringVelocity:0, options:UIViewAnimationOptions(), animations: {
            browser.backgroundView.alpha = 1.0
            self.resizableImageView?.frame = self.finalImageViewFrame
        }, completion: { (Bool) -> Void in
            browser.view.isHidden = false
            browser.view.alpha = 1.0
            self.resizableImageView?.alpha = 0.0
            browser.backgroundView.isHidden = true
        })
    }
    
    func dismissAnimation(_ browser: ISPhotoBrowser, completion: ((Void) -> Void)? = nil) {
        UIView.animate(withDuration: animationDuration, delay:0, usingSpringWithDamping:animationDamping, initialSpringVelocity:0, options:UIViewAnimationOptions(), animations: {
            browser.backgroundView.alpha = 0.0
            self.resizableImageView?.layer.frame = self.senderViewOriginalFrame
        }, completion: { (Bool) -> () in
            browser.dismissPhotoBrowser(animated: true) {
                self.resizableImageView?.removeFromSuperview()
            }
        })
    }
}


