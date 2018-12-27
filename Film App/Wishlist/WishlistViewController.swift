//
//  WishlistViewController.swift
//  Film App
//
//  Created by Вероника Данилова on 27/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import CoreData

class WishlistViewController: UIViewController {
    
    @IBOutlet weak var wishlistTableView: UITableView!
    
    var fetchedResultController: NSFetchedResultsController<Movie>!
    
    struct Predicates {
        static let tvPredicate = NSPredicate(format: "mediaType.name CONTAINS[cd] 'tv'")
        static let moviePredicate = NSPredicate(format: "mediaType.name CONTAINS[cd] 'movie'")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        wishlistTableView.delegate = self
        wishlistTableView.dataSource = self
        
        wishlistTableView.tableFooterView = UIView()
        wishlistTableView.register(UINib(nibName: "WishlistTableViewCell", bundle: nil), forCellReuseIdentifier: "WishlistCell")
        
        fetchData(predicate: Predicates.moviePredicate)
    }
    

    @IBAction func sectionSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            fetchData(predicate: Predicates.tvPredicate)
        } else {
            fetchData(predicate: Predicates.moviePredicate)
        }
        wishlistTableView.reloadData()
    }
    
    private func fetchData(predicate: NSPredicate? = nil) {
        
        fetchedResultController = CoreDataManager.shared.fetchDataWithController(for: Movie.self, predicate: predicate)
        fetchedResultController.delegate = self
        fetchedObjectsCheck(predicate: predicate)
    }
    
    private func fetchedObjectsCheck(predicate: NSPredicate? = nil) {
        
        guard let objects = fetchedResultController.fetchedObjects else {
            return
        }
        
        if objects.count == 0 {
            wishlistTableView.isHidden = true
        } else {
            wishlistTableView.isHidden = false
        }
    }
    
    

}

extension WishlistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let frc = fetchedResultController, let sections = frc.sections else {
            return 0
        }
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let frc = fetchedResultController, let sections = frc.sections else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WishlistCell", for: indexPath)
        
        if let cell = cell as? WishlistTableViewCell {
            
            let item = fetchedResultController.object(at: indexPath)
            cell.configure(with: item)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WishlistTableViewCell
        let storyboard = UIStoryboard(name: "Movie", bundle: nil)
        let movieController = storyboard.instantiateViewController(withIdentifier: "MovieTableViewController") as! MovieTableViewController
        movieController.movieId = cell.id
        if let type = cell.mediaType {
            movieController.mediaType = type
        } else {
            print("Problems with type")
            return
        }
        
        self.navigationController?.pushViewController(movieController, animated: true)
    }

}


extension WishlistViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let removeFromWishlist = UITableViewRowAction(style: .destructive, title: "Remove from wishlist") { (action, indexPath) in
            
            let item = self.fetchedResultController.object(at: indexPath)
            CoreDataManager.shared.delete(object: item)
        }
        
        return [removeFromWishlist]
    }
    
}

extension WishlistViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        wishlistTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            wishlistTableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            wishlistTableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                wishlistTableView.deleteRows(at: [indexPath], with: .fade)
                fetchedObjectsCheck()
            }
            
        case .insert:
            if let indexPath = newIndexPath {
                wishlistTableView.insertRows(at: [indexPath], with: .fade)
                fetchedObjectsCheck()
            }
            
        case .move:
            if let indexPath = indexPath {
                let cell = wishlistTableView.cellForRow(at: indexPath) as! WishlistTableViewCell
                let item = fetchedResultController.object(at: indexPath)
                cell.configure(with: item)
            }
            
        case .update:
            if let indexPath = indexPath {
                let cell = wishlistTableView.cellForRow(at: indexPath) as! WishlistTableViewCell
                let item = fetchedResultController.object(at: indexPath)
                cell.configure(with: item)
            }
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        wishlistTableView.endUpdates()
    }
    
}
