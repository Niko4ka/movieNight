import UIKit
import Alamofire
import Kingfisher

class PersonTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    let personLoadingGroup = DispatchGroup()
    var navigator: ProjectNavigator?
    var personId: Int!
    var personMovies: [PersonMovie] = []
    var personTvShows: [PersonMovie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Spinner.start(from: (self.navigationController?.view)!)
        
        getInfo(personId: personId)
        getMovies(forPersonId: personId)
        getTvShows(forPersonId: personId)
        
        personLoadingGroup.notify(queue: .main) {
            self.tableView.reloadData()
            Spinner.stop()
        }

    }
    
    private func getInfo(personId id: Int) {
        personLoadingGroup.enter()
        
        ConfigurationService.client.loadPersonInfo(id: id) { (info) in
            
            guard let info = info else {
                self.personLoadingGroup.leave()
                return
            }
            
            self.nameLabel.text = info.name
            self.navigationItem.title = info.name
            
            if let department = info.department {
                if department == "Acting" && info.gender == 2 {
                    self.jobLabel.text = "Actor"
                }
                
                if department == "Acting" && info.gender == 1 {
                    self.jobLabel.text = "Actress"
                }
            }
            
            if let profilePath = info.profilePath,
                let url = URL(string: "https://image.tmdb.org/t/p/w185\(profilePath)") {
                self.profileImageView.kf.setImage(with: url)
            } else {
                self.profileImageView.image = UIImage(named: "noPoster")
            }
            
            if let birthday = info.birthday {
                let deathday: String? = info.deathday
                if deathday == nil {
                    let age = birthday.calculateCurrentAge()
                    self.ageLabel.text = age + " years old"
                }
            }
            self.personLoadingGroup.leave()
        }
    }
    
    private func getMovies(forPersonId id: Int) {
        
        personLoadingGroup.enter()
        
        ConfigurationService.client.loadPersonMovies(personId: id) { (movies) in
            self.personMovies = movies
            self.personLoadingGroup.leave()
        }
    }
    
    private func getTvShows(forPersonId id: Int) {
        
        personLoadingGroup.enter()
        
        ConfigurationService.client.loadPersonTvShows(personId: id) { (tvShows) in
            self.personTvShows = tvShows
            self.personLoadingGroup.leave()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if (personTvShows.isEmpty && !personMovies.isEmpty) || (!personTvShows.isEmpty && personMovies.isEmpty) {
            return 1
        } else if personTvShows.isEmpty && personMovies.isEmpty {
            return 0
        } else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 && personMovies.isEmpty {
            return personTvShows.count
        } else if section == 0 && !personMovies.isEmpty {
            return personMovies.count
        } else {
            return personTvShows.count
        }

    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "PersonSectionHeader") as! PersonSectionHeaderCell
        
        if let name = nameLabel.text, !name.isEmpty {
            if section == 0 {
                header.sectionLabel.text = "Movies with \(name)"
            } else {
                header.sectionLabel.text = "TV Shows with \(name)"
            }
        }

        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonMoviesCell", for: indexPath) as! PersonMovieTableViewCell

        if indexPath.section == 0 {
            cell.configure(with: personMovies[indexPath.row])
        } else {
            cell.configure(with: personTvShows[indexPath.row])
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! PersonMovieTableViewCell
        navigator?.navigate(to: .movie(id: cell.id, type: cell.mediaType))
    }

}
