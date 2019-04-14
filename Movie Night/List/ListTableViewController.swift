import UIKit

class ListTableViewController: UITableViewController, ColorThemeCellObserver {
    
    var isDarkTheme: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    var requestType: ListRequest
    var navigator: ProjectNavigator
    
    private var viewModel: ListViewModel?
    
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
        
        configureTableView()
        setupColorThemeObserver()
        setNeedsStatusBarAppearanceUpdate()
        
        viewModel = ListViewModel(request: requestType, delegate: self)
        isLoading = true
        viewModel?.fetchData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if isDarkTheme {
            return .lightContent
        }
        return .default
    }
    
    private func configureTableView() {
        tableView.prefetchDataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "ListCell")
    }
    
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.totalCount ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListTableViewCell
        
        if isLoadingCell(for: indexPath) {
            cell.configure(with: .none)
        } else {
            cell.configure(with: viewModel?.movie(at: indexPath.row))
        }
        
        cell.colorDelegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewModel = viewModel {
            let item = viewModel.movie(at: indexPath.row)
            navigator.navigate(to: .movie(id: item.id, type: item.mediaType))
        }
    }
 
}

extension ListTableViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        if indexPaths.contains(where: isLoadingCell) {
            viewModel?.fetchData()
        }
    }
}

extension ListTableViewController {
    
    func darkThemeEnabled() {
        tableView.backgroundColor = .darkThemeBackground
        isDarkTheme = true
    }
    
    func darkThemeDisabled() {
        tableView.backgroundColor = .white
        isDarkTheme = false
    }
    
}

extension ListTableViewController: ListViewModelDelegate {
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        
        guard let newIndexPaths = newIndexPathsToReload else {
            isLoading = false
            tableView.reloadData()
            return
        }
        
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPaths)
        UIView.performWithoutAnimation {
            tableView.reloadRows(at: indexPathsToReload, with: .none)
        }
        
    }
    
    func onFetchFailed() {
        isLoading = false
        showError()
    }
    
}

private extension ListTableViewController {
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel?.currentCount ?? 0
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
}
