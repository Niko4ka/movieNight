import CoreData
import UIKit

final class CoreDataManager {
    
    static let shared = CoreDataManager(modelName: "Wishlist")
    
    private let modelName: String
    
    private init(modelName: String) {
        self.modelName = modelName
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: modelName)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error - \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    public func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error - \(error), \(error.userInfo)")
            }
        }
    }
    
    public func createObject<T: NSManagedObject>(from entity: T.Type) -> T {
        let context = getContext()
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: entity), into: context) as! T
        return object
    }
    
    public func delete(object: NSManagedObject) {
        let context = getContext()
        context.delete(object)
        save(context: context)
    }
    
    public func fetchDataWithController<T: NSManagedObject>(for entity: T.Type, sectionNameKeyPath: String? = nil, predicate: NSPredicate? = nil) -> NSFetchedResultsController<T>{
        
        let context = getContext()
        let request: NSFetchRequest<T>
        
        if #available(iOS 10.0, *) {
            request = entity.fetchRequest() as! NSFetchRequest<T>
        } else {
            let entityName = String(describing: entity)
            request = NSFetchRequest(entityName: entityName)
        }
        
        let dateSortDescriptor = NSSortDescriptor(key: "saveDate", ascending: false)
        
        request.predicate = predicate
        request.sortDescriptors = [dateSortDescriptor]
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        do {
            try controller.performFetch()
        } catch {
            debugPrint("Couldn't fetch \(error.localizedDescription)")
        }
        
        return controller
    }
    
    public func findMovie(withID id: Int32) -> [Movie] {
        
        let context = getContext()
        
        let request: NSFetchRequest<Movie>
        var fetchedResult = [Movie]()
        
        if #available(iOS 10.0, *) {
            request = Movie.fetchRequest()
        } else {
            let entityName = String(describing: Movie.self)
            request = NSFetchRequest(entityName: entityName)
        }
        
        let predicate = NSPredicate(format: "id = '\(id)'")
        request.predicate = predicate
        
        do {
            fetchedResult = try context.fetch(request)
        } catch {
            debugPrint("Couldn't fetch \(error.localizedDescription)")
        }
        
        return fetchedResult
    }
    
    public func saveItemToWishlist(mediaType: String, data: MovieDetails, poster: UIImage, backdrop: UIImage?, saveDate: Date) {
        
        let context = getContext()
        
        let item = createObject(from: Movie.self)
        item.id = Int32(data.id)
        item.genres = data.genres
        item.poster = poster
        item.rating = data.rating
        item.title = data.title
        item.voteCount = Int16(data.voteCount)
        item.releasedDate = data.releaseDate
        item.saveDate = saveDate
        item.backdrop = backdrop
        
        let itemMediaType = createObject(from: MediaTypeEntity.self)
        itemMediaType.name = mediaType
        item.mediaType = itemMediaType
        
        save(context: context)
    }
    
}
