import UIKit

class MoviesTableViewController: UITableViewController {
    
    var nowPlaying = [DatabaseObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var popular = [DatabaseObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var upcoming = [DatabaseObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var navigator: ProjectNavigator?
    weak var slider: SliderTableViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SliderTableViewCell.self, forCellReuseIdentifier: "SlideCell")
        tableView.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let slider = slider, let timer = slider.timer, timer.isValid {
            timer.invalidate()
        }
    }
    
    private func loadData() {
        
        ConfigurationService.client.loadMoviesCategory(.nowPlaying) { (movies) in
            self.nowPlaying = movies
        }
        
        ConfigurationService.client.loadMoviesCategory(.popular) { (movies) in
            self.popular = movies
        }
        
        ConfigurationService.client.loadMoviesCategory(.upcoming) { (movies) in
            self.upcoming = movies
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SlideCell", for: indexPath) as! SliderTableViewCell
            slider = cell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
            if indexPath.row == 1 {
                cell.data = nowPlaying
                cell.headerTitle.text = "Now in cinemas"
                return cell
            } else if indexPath.row == 2 {
                cell.data = popular
                cell.headerTitle.text = "Popular"
                return cell
            } else {
                cell.data = upcoming
                cell.headerTitle.text = "Upcoming"
                return cell
            }
            
        }
        
    }
 

}
