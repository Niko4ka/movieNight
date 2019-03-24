import UIKit

class ResultsTableViewController: UITableViewController, ColorThemeCellObserver {
    
    var isDarkTheme: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    typealias resultObject = (title: String, objects: [DatabaseObject])
    public var data = [resultObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var keyword: String!
    var navigator: ProjectNavigator?
    
    init(navigator: ProjectNavigator) {
        self.navigator = navigator
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.bounces = false
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        
        setupColorThemeObserver()
    }
    
    private func getRequestType(of objectsTitle: String) -> SearchListRequest? {
        switch objectsTitle {
        case "Movies": return SearchListRequest.movie(keyword: keyword)
        case "tvShows": return SearchListRequest.tvShow(keyword: keyword)
        case "Persons": return SearchListRequest.person(keyword: keyword)
        default: return nil
        }
    }
    
    private func configureCell(_ cell: CollectionTableViewCell, with object: resultObject) {

        cell.navigator = navigator
        cell.colorDelegate = self
        cell.headerTitle.text = object.title
        cell.data = object.objects
        
        if let requestType = getRequestType(of: object.title) {
            cell.requestType = requestType
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
        configureCell(cell, with: data[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

}

extension ResultsTableViewController {
    
    func darkThemeEnabled() {
        tableView.backgroundColor = .darkThemeBackground
        isDarkTheme = true
    }
    
    func darkThemeDisabled() {
        tableView.backgroundColor = .white
        isDarkTheme = false
    }
    
}
