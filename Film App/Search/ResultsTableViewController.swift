import UIKit

class ResultsTableViewController: UITableViewController {
    
    public var data = [(title: String, objects: [DatabaseObject])]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let title = data[indexPath.row].title
        let items = data[indexPath.row].objects
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
        cell.coordinator = self
        cell.headerTitle.text = title
        cell.data = items
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }


}

extension ResultsTableViewController: MovieCoordinator {
    func showMovie(id: Int, type: MediaType) {
        
        let storyboard = UIStoryboard(name: "Movie", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "MovieTableViewController") as? MovieTableViewController else {
            return
        }
        
        controller.movieId = id
        controller.mediaType = type
        
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
}


