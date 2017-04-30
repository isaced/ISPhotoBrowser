//
//  ISCollectionViewLayout.swift
//  Pods
//
//  Created by isaced on 04/26/2017.
//  Copyright (c) 2017 isaced <isaced@163.com> All rights reserved.
//


import UIKit

class ISCollectionViewLayout: UICollectionViewFlowLayout {
    
    var pathForFocusItem: IndexPath?
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        if let pathForFocusItem = pathForFocusItem {
            let layoutAttrs = layoutAttributesForItem(at: pathForFocusItem)
            return CGPoint(x: (layoutAttrs?.frame.origin.x ?? 0) - (collectionView?.contentInset.left ?? 0),
                           y: (layoutAttrs?.frame.origin.y ?? 0) - (collectionView?.contentInset.top ?? 0))
        }else{
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
    }
    
    override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
        self.pathForFocusItem = collectionView?.indexPathsForVisibleItems.first
        print("prepare(forAnimatedBoundsChange...")
    }
    
    override func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        self.pathForFocusItem = nil
    }
}
