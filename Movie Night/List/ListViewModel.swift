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
        
        Client.shared.loadList(of: request, onPage: currentPage) { (result) in
            // TODO: - возможно totalPages не нужен будет???
            switch result {
                
            case .success(let listResults):
                self.total = listResults.totalResults
                self.data.append(contentsOf: listResults.results)
                if self.currentPage > 1 {
                    let indexPathsToReload = self.calculateIndexPathToReload(from: listResults.results)
                    self.delegate?.onFetchCompleted(with: indexPathsToReload)
                } else {
                    self.delegate?.onFetchCompleted(with: .none)
                }
                self.currentPage += 1
                self.isFetchInProgress = false
                
            case .error:
                self.isFetchInProgress = false
                self.delegate?.onFetchFailed()
            }
        }
    }

    private func calculateIndexPathToReload(from newData: [DatabaseObject]) -> [IndexPath] {
        let startIndex = data.count - newData.count
        let endIndex = startIndex + newData.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
}
