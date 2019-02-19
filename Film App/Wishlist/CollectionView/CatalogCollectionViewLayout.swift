import UIKit

struct CatalogLayoutConstants {
    static let standardCellHeight: CGFloat = 100.0
    static let focusedCellHeight: CGFloat = 280.0
}

class CatalogCollectionViewLayout: UICollectionViewLayout {
    
    // MARK: Properties and Variables
    
    let scrollOffset: CGFloat = 180.0
    
    var cache: [UICollectionViewLayoutAttributes] = []
    
    var focusedItemIndex: Int {
        let index = collectionView!.contentOffset.y / scrollOffset
        return max(0, Int(index))
    }
    
    var nextItemPercentageOffset: CGFloat {
        let index = collectionView!.contentOffset.y / scrollOffset
        return index - CGFloat(focusedItemIndex)
    }
    
    var collectionViewWidth: CGFloat {
        return collectionView!.bounds.width
    }
    
    var collectionViewHeight: CGFloat {
        return collectionView!.bounds.height
    }
    
    var numberOfItems: Int {
        return collectionView!.numberOfItems(inSection: 0)
    }
    
    
    // MARK: UICollectionViewLayout
    
    override var collectionViewContentSize: CGSize {
        let contentHeight = (CGFloat(numberOfItems) * scrollOffset) + (collectionViewHeight - scrollOffset)
        return CGSize(width: collectionViewWidth, height: contentHeight)
    }
    
    override func prepare() {
        let standardHeight = CatalogLayoutConstants.standardCellHeight
        let focusedHeight = CatalogLayoutConstants.focusedCellHeight
        
        var frame = CGRect.zero
        var y: CGFloat = 0
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attributes.zIndex = item
            var height = standardHeight
            
            if indexPath.item == focusedItemIndex {
                let yOffset = standardHeight * nextItemPercentageOffset
                y = collectionView!.contentOffset.y - yOffset
                height = focusedHeight
            } else if indexPath.item == (focusedItemIndex + 1) && indexPath.item != numberOfItems {
                let maxY = y + standardHeight
                let scaledPart = (focusedHeight - standardHeight) * nextItemPercentageOffset
                height = standardHeight + max(scaledPart, 0)
                y = maxY - height
            }
            
            frame = CGRect(x: 0, y: y, width: collectionViewWidth, height: height)
            attributes.frame = frame
            cache.append(attributes)
            y = frame.maxY
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let itemIndex = round(proposedContentOffset.y / scrollOffset)
        let yOffset = itemIndex * scrollOffset
        return CGPoint(x: 0, y: yOffset)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

}
