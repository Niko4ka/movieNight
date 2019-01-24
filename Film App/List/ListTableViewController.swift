import UIKit

class ListTableViewController: UITableViewController {
    
    var requestType: ListRequest!
    var navigator: ProjectNavigator!
    
    var data = [DatabaseObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var resultsCount = 0
    var pagesCount = 0
    var loadedPage = 1
    var isLoadingNewData = false
    
    var isLoading: Bool = false {
        didSet {
            updateLoading()
        }
    }
    
    private func updateLoading() {
        if isLoading {
            let activity = UIActivityIndicatorView(style: .gray)
            activity.startAnimating()
            
            tableView.backgroundView = activity
            tableView.tableHeaderView = nil
        } else {
            tableView.backgroundView = nil
        }
        tableView.reloadData()
    }
    
    init(requestType: ListRequest, title: String, navigator: ProjectNavigator) {
        self.requestType = requestType
        self.navigator = navigator
        super.init(style: .plain)
        self.navigationItem.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        loadData(request: requestType) {
            self.tableView.reloadData()
        }

    }
    
    private func loadData(request: ListRequest, completion: @escaping ()->Void) {
        isLoading = true
        Client.shared.loadList(of: request, onPage: loadedPage) { (results, totalPages, totalResults) in
            self.data = self.data + results
            self.resultsCount = totalResults
            self.pagesCount = totalPages
            self.isLoadingNewData = false
            self.isLoading = false
            completion()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsCount
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListTableViewCell
        if indexPath.row < data.count {
            cell.configure(with: data[indexPath.row])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigator.navigate(to: .movie(id: data[indexPath.row].id, type: .movie))
    }
 
}

extension ListTableViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        print("Prepare cells in indexPath - \(indexPaths)")
        
        // TODO: нужно добавить проверку, чтобы текущая страница не была out of range
        
        indexPaths.forEach {
            if $0.row >= data.count && !isLoadingNewData {
                isLoadingNewData = true
                loadedPage += 1
                loadData(request: requestType, completion: {
                    self.tableView.reloadRows(at: indexPaths, with: .automatic)
                })
            }
        }
       
    }
    
    
}
