//
//  PersonTableViewController.swift
//  Film App
//
//  Created by Вероника Данилова on 27/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class PersonTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    let personLoadingGroup = DispatchGroup()
    var personId: Int!
    var personMovies: [PersonMovie] = []
    var personTvShows: [PersonMovie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Spinner.start(from: (self.navigationController?.view)!)
        
        getInfo(forPersonId: personId)
        getMovies(forPersonId: personId)
        getTvShows(forPersonId: personId)
        
        personLoadingGroup.notify(queue: .main) {
            self.tableView.reloadData()
            Spinner.stop()
        }

    }
    
    private func getInfo(forPersonId id: Int) {
        personLoadingGroup.enter()
        
        AF.request("https://api.themoviedb.org/3/person/\(id)?api_key=\(ConfigurationService.themoviedbKey)").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else { return }
            
            if let name = json["name"] as? String {
                self.nameLabel.text = name
                self.navigationItem.title = name
            }
            
            if let department = json["known_for_department"] as? String,
                let gender = json["gender"] as? Int {
                if department == "Acting" && gender == 2 {
                    self.jobLabel.text = "Actor"
                }
                
                if department == "Acting" && gender == 1 {
                    self.jobLabel.text = "Actress"
                }
            }
            
            if let profileUrl = json["profile_path"] as? String,
                let url = URL(string: "https://image.tmdb.org/t/p/w185\(profileUrl)") {
                self.profileImageView.kf.setImage(with: url)
            }
            
            if let birthday = json["birthday"] as? String {
                let deathday: String? = json["deathday"] as? String
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
        
        AF.request("https://api.themoviedb.org/3/person/\(id)/movie_credits?api_key=\(ConfigurationService.themoviedbKey)").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else { return }
            guard let cast = json["cast"] as? [Dictionary<String, Any>] else { return }
            
            for itemJson in cast {
                if let personMovie = PersonMovie(ofType: .movie, from: itemJson) {
                    self.personMovies.append(personMovie)
                }
            }
            
            self.personLoadingGroup.leave()
        }
    }
    
    private func getTvShows(forPersonId id: Int) {
        
        personLoadingGroup.enter()
        
        AF.request("https://api.themoviedb.org/3/person/\(id)/tv_credits?api_key=\(ConfigurationService.themoviedbKey)").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else { return }
            guard let cast = json["cast"] as? [Dictionary<String, Any>] else { return }
            
            for itemJson in cast {
                if let personTvShow = PersonMovie(ofType: .tvShow, from: itemJson) {
                    self.personTvShows.append(personTvShow)
                }
            }
            
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
        
        let storyboard = UIStoryboard(name: "Movie", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "MovieTableViewController") as? MovieTableViewController else {
            return
        }
        
        controller.movieId = cell.id
        controller.mediaType = cell.mediaType

        self.navigationController?.pushViewController(controller, animated: true)
        
    }

}
