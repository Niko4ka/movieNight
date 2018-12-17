//
//  MovieViewController.swift
//  Film App
//
//  Created by Вероника Данилова on 14/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class MovieViewController: UIViewController {
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var genresLable: UILabel!
    @IBOutlet weak var releasedLabel: UILabel!
    @IBOutlet weak var addToWishlistButton: UIButton!
    @IBOutlet weak var movieDetailsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var movieDetailsContainerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var reviewsContainerView: UIView!
    @IBOutlet weak var reviewsContainerViewHeight: NSLayoutConstraint!
    
    
    

    public var mediaType: String!
    public var movieId: Int!
    public var genres: String!
    
    private var movieDetailsController: MovieDetailsTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reviewsContainerView.isHidden = true
        self.movieDetailsContainerView.isHidden = false
        
        guard let id = movieId else { return }
        
        switch mediaType {
        case "movie":
            print("Movie")
            loadMovieData(forID: id)
        case "tv":
            print("TV")
            loadTvShowData(forID: id)
        default:
            ()
        }

        
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.reviewsContainerView.isHidden = true
            self.movieDetailsContainerView.isHidden = false
        } else {
            self.reviewsContainerView.isHidden = false
            self.movieDetailsContainerView.isHidden = true
            reviewsContainerViewHeight.constant = 2000
        }
    }
    
    

    
    // Private
    
    private func loadMovieData(forID id: Int) {
        
        AF.request("https://api.themoviedb.org/3/movie/\(id)?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en-US").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else {
                print("error")
                return
            }
            
//            if let imageString = json["poster_path"] as? String {
//                let imageUrl = URL(string: "https://image.tmdb.org/t/p/w500/\(imageString)")
//                self.movieImageView.kf.setImage(with: imageUrl)
//            }
            
//            if let title = json["title"] as? String {
//                self.movieTitleLabel.text = title
//            }
            
//            if let releaseDate = json["release_date"] as? String {
//                self.releasedLabel.text?.append(releaseDate)
//            }
            
            


            

            
            self.genresLable.text = self.genres
        }
        
        AF.request("https://api.themoviedb.org/3/movie/\(id)/credits?api_key=81c0943d1596e1cc2b1c8de9e9ba8945").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let cast = json["cast"] as? [Dictionary<String, Any>],
                let crew = json["crew"] as? [Dictionary<String, Any>] else {
                    print("error")
                    return
            }
            
            var castQuantity: Int!
            if cast.count >= 10 {
                castQuantity = 10
            } else {
                castQuantity = cast.count
            }
            
            for i in 0..<castQuantity {
                let actor = cast[i]
                if let name = actor["name"] as? String {
                    let actorLabel = UILabel()
                    actorLabel.font = UIFont.systemFont(ofSize: 13.0)
                    actorLabel.textColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
                    actorLabel.text = name
                    self.movieDetailsController.castStackView.addArrangedSubview(actorLabel)
                }
            }
            
            for member in crew {
                guard let job = member["job"] as? String,
                    let name = member["name"] as? String else { return }

                switch job {
                case "Director":
                    self.movieDetailsController.directorLabel.text = name + "\n"
                case "Writer":
                    self.movieDetailsController.writerLabel.text = name + "\n"
                case "Producer":
                    let producerLabel = UILabel()
                    producerLabel.font = UIFont.systemFont(ofSize: 13.0)
                    producerLabel.textColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
                    producerLabel.text = name
                    self.movieDetailsController.crewStackView.addArrangedSubview(producerLabel)
                default:
                    ()
                }
            }
            
            if (self.movieDetailsController.writerLabel.text?.isEmpty)! {
                print("Writer text empty")
                self.movieDetailsController.writerTitleLabel.removeFromSuperview()
                self.movieDetailsController.writerLabel.removeFromSuperview()
            }

            if let lastCrewElement = self.movieDetailsController.crewStackView.arrangedSubviews.last as? UILabel {
                if lastCrewElement.text == "Producers" {
                    lastCrewElement.removeFromSuperview()
                }
            }
            
            if (self.movieDetailsController.directorLabel.text?.isEmpty)! {
                guard let firstCrewElement = self.movieDetailsController.crewStackView.arrangedSubviews.first as? UILabel else { return }
                firstCrewElement.removeFromSuperview()
            }
            
            self.movieDetailsController.tableView.reloadData()
            self.containerViewHeight.constant = self.movieDetailsController.getHeightOfLastCell()            
        }
    }
    
    private func loadTvShowData(forID id: Int) {
        
        AF.request("https://api.themoviedb.org/3/tv/\(id)?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en-US").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else {
                print("error")
                return
            }
            
//            if let imageString = json["poster_path"] as? String {
//                let imageUrl = URL(string: "https://image.tmdb.org/t/p/w500/\(imageString)")
//
//                self.movieImageView.kf.indicatorType = .activity
//                self.movieImageView.contentMode = .scaleAspectFit
//                self.movieImageView.kf.setImage(with: imageUrl)
//            }
            
//            if let title = json["name"] as? String {
//                self.movieTitleLabel.text = title
//            }
            
//            if let description = json["overview"] as? String {
//                self.movieDetailsController.descriptionTextView.text = description
//                self.movieDetailsController.descriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
//                self.movieDetailsController.descriptionTextView.textContainerInset = .zero
//                self.movieDetailsController.descriptionTextView.textContainer.lineFragmentPadding = 0
//                let height = self.movieDetailsController.getTextViewHeight(fromText: self.movieDetailsController.descriptionTextView.text)
//                if height <= self.movieDetailsController.descriptionHeight.constant {
//                    self.movieDetailsController.descriptionHeight.constant = height
//                    self.movieDetailsController.showMoreButton.isHidden = true
//                }
//            }
            
//            if let releaseDate = json["first_air_date"] as? String {
//                self.releasedLabel.text?.append(releaseDate)
//            }
            
//            self.genresLable.text = self.genres
            
//            if let seasons = json["number_of_seasons"] as? Int {
//                self.movieDetailsController.title1.text = "Seasons"
//                self.movieDetailsController.text1.text = "\(seasons)"
//
//            }
            
//            if let countries = json["origin_country"] as? [String] {
//                self.movieDetailsController.title2.text = "Country"
//                self.movieDetailsController.text2.text?.removeAll()
//
//            }
            
//            if let status = json["status"] as? String {
//                self.movieDetailsController.title3.text = "Status"
//                self.movieDetailsController.text3.text = status
//            }
            
        }
        
        
        
        AF.request("https://api.themoviedb.org/3/tv/\(id)/credits?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en-US").responseJSON { (response) in
            
            print("Request - \(response.request)")
            
            guard let json = response.result.value as? [String: Any],
                let cast = json["cast"] as? [Dictionary<String, Any>],
                let crew = json["crew"] as? [Dictionary<String, Any>] else {
                    print("error")
                    return
            }


        }
        
    }
    

}
