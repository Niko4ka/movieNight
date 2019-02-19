import CoreData

extension WishlistCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            collectionView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
        case .delete:
            collectionView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                collectionView.deleteItems(at: [indexPath])
                fetchedObjectsCheck()
            }
            
        case .insert:
            if let indexPath = newIndexPath {
                collectionView.insertItems(at: [indexPath])
                fetchedObjectsCheck()
            }
            
        case .move:
            if let indexPath = indexPath {
                let cell =  collectionView.cellForItem(at: indexPath) as! WishlistCollectionViewCell
                let item = fetchedResultController.object(at: indexPath)
                cell.configure(with: item)
            }
            
        case .update:
            if let indexPath = indexPath {
                let cell =  collectionView.cellForItem(at: indexPath) as! WishlistCollectionViewCell
                let item = fetchedResultController.object(at: indexPath)
                cell.configure(with: item)
            }
            
        }
    }
    
}
