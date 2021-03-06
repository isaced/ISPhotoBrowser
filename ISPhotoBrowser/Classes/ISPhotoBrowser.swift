//
//  ISPhotoBrowser.swift
//  Pods
//
//  Created by isaced on 04/26/2017.
//  Copyright (c) 2017 isaced <isaced@163.com> All rights reserved.
//

import UIKit

internal let ISPhotoCellMargin = 20.0

open class ISPhotoBrowser: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private lazy var photoCollectionView: UICollectionView = {
        return UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: ISCollectionViewLayout())
    }()

    // data
    internal var photos: [ISPhotoProtocol] = []
    
    // delegate
    fileprivate let animator = ISAnimator()
    open weak var delegate: ISPhotoBrowserDelegate?
    
    internal var backgroundView: UIView!
    fileprivate var panGesture: UIPanGestureRecognizer!
    
    // pangesture property
    fileprivate var firstX: CGFloat = 0.0
    fileprivate var firstY: CGFloat = 0.0
    
    // === Customize ===
    
    /// Set the initial page
    public var initialPageIndex: Int = 0
    
    /// Get the current page number of the photo browser
    ///
    /// If you want to change current page, pleasecall scrollToPage()
    public fileprivate(set) var currentPageIndex: Int = 0
    
    /// Set the background color of the photo browser
    public var backgroundColor: UIColor = UIColor.black {
        didSet{
            self.backgroundView?.backgroundColor = backgroundColor
        }
    }
    
    /// Whether to enable click disappears
    public var enableSingleTapDismiss: Bool = true
    
    // === Customize ===
    
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
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        photos.forEach { (photo) in
            photo.unloadUnderlyingImage()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.ISPhotoSingleTapAction, object: nil)
    }
    
    func setup() {
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }
    
    open override func viewDidLoad() {
        
        view.backgroundColor = self.backgroundColor
        
        // Collection View
        if let collectionViewLayout = photoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.scrollDirection = .horizontal
            collectionViewLayout.minimumLineSpacing = 0
            collectionViewLayout.minimumInteritemSpacing = 0
            collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }

        photoCollectionView.isPagingEnabled = true
        photoCollectionView.showsVerticalScrollIndicator = false
        photoCollectionView.showsHorizontalScrollIndicator = false
        photoCollectionView.register(ISPhotoCell.self, forCellWithReuseIdentifier: "ISPhotoCell")
        photoCollectionView.backgroundColor = .clear
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(photoCollectionView)
        self.view.addConstraints([NSLayoutConstraint(item: photoCollectionView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
                                  NSLayoutConstraint(item: photoCollectionView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0),
                                  NSLayoutConstraint(item: photoCollectionView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: CGFloat(ISPhotoCellMargin)),
                                  NSLayoutConstraint(item: photoCollectionView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)])
        
        // Backgorund view
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        backgroundView.backgroundColor = self.backgroundColor
        backgroundView.alpha = 0.0
        self.view.addSubview(backgroundView)
        
        self.view.layoutIfNeeded()
        
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
        
        delegate?.didShowPhotoAtIndex?(currentPageIndex)
        
        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleSingleTap(_:)), name: NSNotification.Name.ISPhotoSingleTapAction, object: nil)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for cell in photoCollectionView.visibleCells {
            if let cell = cell as? ISPhotoCell {
                cell.updateZoomScalesForCurrentBounds()
            }
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let flowLayout = photoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        // force layout for update item size
        flowLayout.invalidateLayout()
        
        delegate?.didShowPhotoAtIndex?(currentPageIndex)
    }
    
    // MARK: - UICollectionViewDataSource
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ISPhotoCell", for: indexPath) as! ISPhotoCell
        cell.photo = photos[indexPath.row]
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width + CGFloat(ISPhotoCellMargin), height: view.frame.height)
    }
    
    // MARK: -
    
    func photoAtIndex(_ index: Int) -> ISPhotoProtocol {
        return photos[index]
    }
    
    ///  To turn the page
    ///
    ///  - parameter pageIndex: The page number to go
    ///  - parameter animated: Whether to scroll past
    public func scrollToPage(pageIndex: Int, animated: Bool) {
        if pageIndex != currentPageIndex {
            let indexPath = IndexPath(item: pageIndex, section: 0)
            self.photoCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        }
    }
    
    // MARK: -
    func getImageFromView(_ sender: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(sender.frame.size, true, 0.0)
        sender.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    open func dismissPhotoBrowser(animated: Bool, completion: ((Void) -> Void)? = nil) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        if !animated {
            modalTransitionStyle = .crossDissolve
        }
        
        dismiss(animated: !animated) {
            completion?()
            self.delegate?.didDismissAtPageIndex?(self.currentPageIndex)
        }
    }
    
    open func determineAndClose() {
        delegate?.willDismissAtPageIndex?(currentPageIndex)
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
            
            setNeedsStatusBarAppearanceUpdate()
        }
        
        translatedPoint = CGPoint(x: firstX, y: firstY + translatedPoint.y)
        zoomingScrollView.center = translatedPoint
        
        let minOffset: CGFloat = viewHalfHeight / 4
        let offset: CGFloat = 1 - (zoomingScrollView.center.y > viewHalfHeight
            ? zoomingScrollView.center.y - viewHalfHeight
            : -(zoomingScrollView.center.y - viewHalfHeight)) / viewHalfHeight
        
        view.backgroundColor = self.backgroundColor.withAlphaComponent(offset)
        
        // gesture end
        if sender.state == .ended {
            
            if zoomingScrollView.center.y > viewHalfHeight + minOffset
                || zoomingScrollView.center.y < viewHalfHeight - minOffset {
                
                backgroundView.backgroundColor = self.backgroundColor
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
                view.backgroundColor = self.backgroundColor
                zoomingScrollView.center = CGPoint(x: finalX, y: finalY)
                UIView.commitAnimations()
            }
        }
    }

    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        if self.enableSingleTapDismiss {
            determineAndClose()
        }
    }
}

// MARK: -  UICollectionViewDelegate<UIScrollView> Delegate

extension ISPhotoBrowser: UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Calculate current page
        let previousCurrentPage = currentPageIndex
        let visibleBounds = scrollView.bounds
        currentPageIndex = min(max(Int(floor(visibleBounds.midX / visibleBounds.width)), 0), photos.count - 1)
        
        if currentPageIndex != previousCurrentPage {
            delegate?.didShowPhotoAtIndex?(currentPageIndex)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = scrollView.contentOffset.x / scrollView.frame.size.width
        delegate?.didScrollToIndex?(Int(currentIndex))
    }
}

