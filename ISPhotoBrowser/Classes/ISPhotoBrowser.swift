//
//  ISPhotoBrowser.swift
//  Pods
//
//  Created by isaced on 04/26/2017.
//  Copyright (c) 2017 isaced <isaced@163.com> All rights reserved.
//

import UIKit

let ISPhotoCellMargin = 20.0

public class ISPhotoBrowser: UIViewController, UICollectionViewDataSource {
    
    lazy var photoCollectionView: UICollectionView = {
        return UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    }()

    // data
    var photos: [ISPhotoProtocol] = []
    
    // delegate
    fileprivate let animator = ISAnimator()
    open weak var delegate: ISPhotoBrowserDelegate?
    
    public var initialPageIndex: Int = 0
    public var currentPageIndex: Int = 0
    
    var backgroundView: UIView!
    fileprivate var panGesture: UIPanGestureRecognizer!
    
    // pangesture property
    fileprivate var firstX: CGFloat = 0.0
    fileprivate var firstY: CGFloat = 0.0
    
    public convenience init(photos: [ISPhotoProtocol]) {
        self.init(nibName: nil, bundle: nil)
        self.photos = photos
    }
    
    public convenience init(photos: [ISPhotoProtocol], originImage: UIImage, animatedFromView: UIView) {
        self.init(photos: photos)
        animator.senderOriginImage = originImage
        animator.senderViewForAnimation = animatedFromView
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        photos.forEach { (photo) in
            photo.unloadUnderlyingImage()
        }
    }
    
    deinit {
        print("ISPhotoBrowser deinit...")
    }
    
    func setup() {
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }
    
    override public func viewDidLoad() {
        
        view.backgroundColor = .black
        
        // Collection View
        if let collectionViewLayout = photoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.itemSize = CGSize(width: UIScreen.main.bounds.width + CGFloat(ISPhotoCellMargin), height: UIScreen.main.bounds.height)
            collectionViewLayout.scrollDirection = .horizontal
            collectionViewLayout.minimumLineSpacing = 0
            collectionViewLayout.minimumInteritemSpacing = 0
            collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
        
        photoCollectionView.frame.size.width = UIScreen.main.bounds.size.width + CGFloat(ISPhotoCellMargin)
        photoCollectionView.isPagingEnabled = true
        photoCollectionView.showsVerticalScrollIndicator = true
        photoCollectionView.showsHorizontalScrollIndicator = true
        photoCollectionView.register(ISPhotoCell.self, forCellWithReuseIdentifier: "ISPhotoCell")
        photoCollectionView.backgroundColor = .clear
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        self.view.addSubview(photoCollectionView)
        
        // Backgorund view
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.0
        self.view.addSubview(backgroundView)
        
        // init page
        if initialPageIndex != 0 {
            scrollToPage(pageIndex: initialPageIndex, animated: false)
        }
        
        // Pan Gesture
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(ISPhotoBrowser.panGestureRecognized(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)
        
        // present animation
        animator.willPresent(self)
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ISPhotoCell", for: indexPath) as! ISPhotoCell
        cell.photo = photos[indexPath.row]
        return cell
    }
    
    // MARK: -
    
    func photoAtIndex(_ index: Int) -> ISPhotoProtocol {
        return photos[index]
    }
    
    func scrollToPage(pageIndex: Int, animated: Bool) {
        let indexPath = IndexPath(item: pageIndex, section: 0)
        self.photoCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    // MARK: -
    func getImageFromView(_ sender: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(sender.frame.size, true, 0.0)
        sender.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    open func prepareForClosePhotoBrowser() {
//        cancelControlHiding()
//        applicationWindow.removeGestureRecognizer(panGesture)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    open func dismissPhotoBrowser(animated: Bool, completion: ((Void) -> Void)? = nil) {
        prepareForClosePhotoBrowser()
        
        if !animated {
            modalTransitionStyle = .crossDissolve
        }
        
        dismiss(animated: !animated) {
            completion?()
//            self.delegate?.didDismissAtPageIndex?(self.currentPageIndex)
        }
    }
    
    open func determineAndClose() {
//        delegate?.willDismissAtPageIndex?(currentPageIndex)
        animator.willDismiss(self)
    }

    func pageDisplayedAtIndex(_ index: Int) -> ISZoomingScrollView? {
        if let cell = self.photoCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ISPhotoCell {
            return cell.zoomingScrollView
        }
        return nil
    }
    
    func panGestureRecognized(_ sender: UIPanGestureRecognizer) {
        guard let zoomingScrollView: ISZoomingScrollView = self.pageDisplayedAtIndex(currentPageIndex) else {
            return
        }
        
        backgroundView.isHidden = true
        
        let viewHeight: CGFloat = zoomingScrollView.frame.size.height
        let viewHalfHeight: CGFloat = viewHeight/2
        var translatedPoint: CGPoint = sender.translation(in: self.view)
        
        // gesture began
        if sender.state == .began {
            firstX = zoomingScrollView.center.x
            firstY = zoomingScrollView.center.y
            
//            hideControls()
            setNeedsStatusBarAppearanceUpdate()
        }
        
        translatedPoint = CGPoint(x: firstX, y: firstY + translatedPoint.y)
        zoomingScrollView.center = translatedPoint
        
        let minOffset: CGFloat = viewHalfHeight / 4
        let offset: CGFloat = 1 - (zoomingScrollView.center.y > viewHalfHeight
            ? zoomingScrollView.center.y - viewHalfHeight
            : -(zoomingScrollView.center.y - viewHalfHeight)) / viewHalfHeight
        
        print("offset: \(offset)")
        
        view.backgroundColor = UIColor.black.withAlphaComponent(offset)
        
        // gesture end
        if sender.state == .ended {
            
            if zoomingScrollView.center.y > viewHalfHeight + minOffset
                || zoomingScrollView.center.y < viewHalfHeight - minOffset {
                
                backgroundView.backgroundColor = view.backgroundColor
                determineAndClose()
                
            } else {
                // Continue Showing View
                setNeedsStatusBarAppearanceUpdate()
                
                let velocityY: CGFloat = CGFloat(0.35) * sender.velocity(in: self.view).y
                let finalX: CGFloat = firstX
                let finalY: CGFloat = viewHalfHeight
                
                let animationDuration: Double = Double(abs(velocityY) * 0.0002 + 0.2)
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(animationDuration)
                UIView.setAnimationCurve(UIViewAnimationCurve.easeIn)
                view.backgroundColor = .black
                zoomingScrollView.center = CGPoint(x: finalX, y: finalY)
                UIView.commitAnimations()
            }
        }
    }

}

// MARK: -  UICollectionViewDelegate<UIScrollView> Delegate

extension ISPhotoBrowser: UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Calculate current page
        let visibleBounds = scrollView.bounds
        currentPageIndex = min(max(Int(floor(visibleBounds.midX / visibleBounds.width)), 0), photos.count - 1)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = scrollView.contentOffset.x / scrollView.frame.size.width
        print("scrollViewDidEndDecelerating currentIndex: \(currentIndex)")
    }
}

