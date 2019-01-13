import UIKit

class MoviesTableViewController: UITableViewController {
    
    var navigator: ProjectNavigator?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SliderTableViewCell.self, forCellReuseIdentifier: "SlideCell")
        tableView.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SlideCell", for: indexPath) as! SliderTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath)
            return cell
        }
        
    }
 

}
