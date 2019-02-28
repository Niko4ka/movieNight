import UIKit
import Kingfisher

class PersonTableViewController: UITableViewController, ColorThemeCellObserver {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    let personLoadingGroup = DispatchGroup()
    var navigator: ProjectNavigator?
    var personId: Int!
    var personMovies: [PersonMovie] = []
    var personTvShows: [PersonMovie] = []
    
    var isLoading: Bool = false {
        didSet {
            updateLoading()
        }
    }
    
    var isDarkTheme: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    private func updateLoading() {
        if isLoading {
            let activity = UIActivityIndicatorView(style: .gray)
            activity.startAnimating()
            
            tableView.backgroundView = activity
            tableView.tableHeaderView?.isHidden = true
        } else {
            tableView.backgroundView = nil
            tableView.tableHeaderView?.isHidden = false
        }
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        isLoading = true
        
        addColorThemeObservers()
        checkCurrentColorTheme()
        
        getInfo(personId: personId)
        getMovies(forPersonId: personId)
        getTvShows(forPersonId: personId)
        
        personLoadingGroup.notify(queue: .main) {
            self.tableView.reloadData()
            self.isLoading = false
        }

    }
    
    private func getInfo(personId id: Int) {
        personLoadingGroup.enter()
        
        Client.shared.loadPersonInfo(id: id) { (info) in
            
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
                
                if department == "Acting" && info.gender == 0 {
                    self.jobLabel.text = ""
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
        
        Client.shared.loadPersonMovies(personId: id) { (movies) in
            self.personMovies = movies
            self.personLoadingGroup.leave()
        }
    }
    
    private func getTvShows(forPersonId id: Int) {
        
        personLoadingGroup.enter()
        
        Client.shared.loadPersonTvShows(personId: id) { (tvShows) in
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
        header.colorDelegate = self

        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonMoviesCell", for: indexPath) as! PersonMovieTableViewCell

        if indexPath.section == 0 {
            cell.configure(with: personMovies[indexPath.row])
        } else {
            cell.configure(with: personTvShows[indexPath.row])
        }
        cell.colorDelegate = self

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! PersonMovieTableViewCell
        navigator?.navigate(to: .movie(id: cell.id, type: cell.mediaType))
    }

}

extension PersonTableViewController {
    
    func darkThemeEnabled() {
        profileImageView.superview?.backgroundColor = .darkThemeBackground
        tableView.backgroundColor = .darkThemeBackground
        profileImageView.backgroundColor = .darkThemeBackground
        nameLabel.textColor = .white
        jobLabel.textColor = .lightText
        ageLabel.textColor = .lightText
        isDarkTheme = true
    }
    
    func darkThemeDisabled() {
        profileImageView.superview?.backgroundColor = .white
        tableView.backgroundColor = .white
        profileImageView.backgroundColor = .white
        nameLabel.textColor = .darkText
        jobLabel.textColor = .darkGray
        ageLabel.textColor = .darkGray
        isDarkTheme = false
    }
    
}
