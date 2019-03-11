import Foundation

protocol ListViewModelDelegate: class {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed()
}

final class ListViewModel {
    
    private weak var delegate: ListViewModelDelegate?
    
    private var data = [DatabaseObject]()
    private var currentPage = 1
    private var total = 0
    private var isFetchInProgress = false
    
    let request: ListRequest
    
    var totalCount: Int {
        return total
    }
    
    var currentCount: Int {
        return data.count
    }
    
    init(request: ListRequest, delegate: ListViewModelDelegate) {
        self.request = request
        self.delegate = delegate
    }
    
    func movie(at index: Int) -> DatabaseObject {
        return data[index]
    }
    
    func fetchData() {
        
        guard !isFetchInProgress else { return }
        
        isFetchInProgress = true
        
        Client.shared.loadList(of: request, onPage: currentPage) { (results, totalPages, totalResults) in
            
            // TODO: - возможно totalPages не нужен будет???
            
            guard !results.isEmpty else {
                self.isFetchInProgress = false
                self.delegate?.onFetchFailed()
                return
            }
            
            
            
            self.total = totalResults
            self.data.append(contentsOf: results)
            
//            self.delegate?.onFetchCompleted(with: .none)
            
            if self.currentPage > 1 {
                let indexPathsToReload = self.calculateIndexPathToReload(from: results)
                self.delegate?.onFetchCompleted(with: indexPathsToReload)
            } else {
                self.delegate?.onFetchCompleted(with: .none)
            }
            
            self.currentPage += 1
            self.isFetchInProgress = false
        }
        
        
    }

    private func calculateIndexPathToReload(from newData: [DatabaseObject]) -> [IndexPath] {
        let startIndex = data.count - newData.count
        let endIndex = startIndex + newData.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    
}
