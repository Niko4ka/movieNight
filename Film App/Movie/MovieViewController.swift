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
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet weak var castStackView: UIStackView!
    @IBOutlet weak var crewStackView: UIStackView!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var writerTitleLabel: UILabel!
    @IBOutlet weak var writerLabel: UILabel!
    @IBOutlet weak var informationTopConstraint: NSLayoutConstraint!
    
    
    // Information
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var title2: UILabel!
    @IBOutlet weak var title3: UILabel!
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var text2: UILabel!
    @IBOutlet weak var text3: UILabel!

    
    public var mediaType: String!
    public var movieId: Int!
    public var genres: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func showMoreButtonPressed(_ sender: UIButton) {
        let height = getTextViewHeight(fromText: descriptionTextView.text)
        descriptionHeight.constant = height
        self.view.layoutIfNeeded()
        showMoreButton.isHidden = true
    }
    
    // Private
    
    private func loadMovieData(forID id: Int) {
        
        AF.request("https://api.themoviedb.org/3/movie/\(id)?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en-US").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else {
                print("error")
                return
            }
            
            if let imageString = json["poster_path"] as? String {
                let imageUrl = URL(string: "https://image.tmdb.org/t/p/w500/\(imageString)")
                self.movieImageView.kf.setImage(with: imageUrl)
            }
            
            if let title = json["title"] as? String {
                self.movieTitleLabel.text = title
            }
            
            if let description = json["overview"] as? String {
                self.descriptionTextView.text = description
                self.descriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
                self.descriptionTextView.textContainerInset = .zero
                self.descriptionTextView.textContainer.lineFragmentPadding = 0
                let height = self.getTextViewHeight(fromText: self.descriptionTextView.text)
                if height <= self.descriptionHeight.constant {
                    self.descriptionHeight.constant = height
                    self.showMoreButton.isHidden = true
                }
            }
            
            if let releaseDate = json["release_date"] as? String {
                self.releasedLabel.text?.append(releaseDate)
            }
            
            if let countries = json["production_countries"] as? [Dictionary<String, String>] {
                self.title1.text = "Country"
                self.text1.text?.removeAll()
                for country in countries {
                    if let countryName = country["name"] {
                        if (self.text1.text?.isEmpty)! {
                            self.text1.text = countryName + " "
                        } else {
                            self.text1.text?.append(countryName + " ")
                        }
                        
                    }
                }
            }
            
            if let status = json["status"] as? String {
                self.title2.text = "Status"
                self.text2.text = status
            }
            
            if let runtime = json["runtime"] as? Int {
                self.title3.text = "Runtime"
                self.text3.text = "\(runtime) min."
            }
            
            self.genresLable.text = self.genres
        }
        
        AF.request("https://api.themoviedb.org/3/movie/\(id)/credits?api_key=81c0943d1596e1cc2b1c8de9e9ba8945").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let cast = json["cast"] as? [Dictionary<String, Any>],
                let crew = json["crew"] as? [Dictionary<String, Any>] else {
                    print("error")
                    return
            }
            //
            //            cast.sort(by: { (person1, person2) -> Bool in
            //                let order1 = person1["order"] as! Int
            //                let order2 = person2["order"] as! Int
            //                return order1 < order2
            //            })
            
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
                    self.castStackView.addArrangedSubview(actorLabel)
                }
            }
            
            for member in crew {
                guard let job = member["job"] as? String,
                    let name = member["name"] as? String else { return }
                
                switch job {
                case "Director":
                    self.directorLabel.text = name + "\n"
                case "Writer":
                    self.writerLabel.text = name + "\n"
                case "Producer":
                    let producerLabel = UILabel()
                    producerLabel.font = UIFont.systemFont(ofSize: 13.0)
                    producerLabel.textColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
                    producerLabel.text = name
                    self.crewStackView.addArrangedSubview(producerLabel)
                default:
                    ()
                }
            }
            
            if (self.writerLabel.text?.isEmpty)! {
                print("Writer text empty")
                self.writerTitleLabel.removeFromSuperview()
                self.writerLabel.removeFromSuperview()
            }
            
            if let lastCrewElement = self.crewStackView.arrangedSubviews.last as? UILabel {
                if lastCrewElement.text == "Producers" {
                    lastCrewElement.removeFromSuperview()
                }
            }
            
            if (self.directorLabel.text?.isEmpty)! {
                guard let firstCrewElement = self.crewStackView.arrangedSubviews.first as? UILabel else { return }
                firstCrewElement.removeFromSuperview()
            }
            
        }
    }
    
    private func loadTvShowData(forID id: Int) {
        
        AF.request("https://api.themoviedb.org/3/tv/\(id)?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en-US").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else {
                print("error")
                return
            }
            
            if let imageString = json["poster_path"] as? String {
                let imageUrl = URL(string: "https://image.tmdb.org/t/p/w500/\(imageString)")
                
                self.movieImageView.kf.indicatorType = .activity
                self.movieImageView.contentMode = .scaleAspectFit
                self.movieImageView.kf.setImage(with: imageUrl)
            }
            
            if let title = json["name"] as? String {
                self.movieTitleLabel.text = title
            }
            
            if let description = json["overview"] as? String {
                self.descriptionTextView.text = description
                self.descriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
                self.descriptionTextView.textContainerInset = .zero
                self.descriptionTextView.textContainer.lineFragmentPadding = 0
                let height = self.getTextViewHeight(fromText: self.descriptionTextView.text)
                if height <= self.descriptionHeight.constant {
                    self.descriptionHeight.constant = height
                    self.showMoreButton.isHidden = true
                }
            }
            
            if let releaseDate = json["first_air_date"] as? String {
                self.releasedLabel.text?.append(releaseDate)
            }
            
            self.genresLable.text = self.genres
            
            // TODO: Add information
            
            if let seasons = json["number_of_seasons"] as? Int {
                self.title1.text = "Seasons"
                self.text1.text = "\(seasons)"
                
            }
            
            if let countries = json["origin_country"] as? [String] {
                self.title2.text = "Country"
                self.text2.text?.removeAll()
                for country in countries {
                        if (self.text2.text?.isEmpty)! {
                            self.text2.text = country + " "
                        } else {
                            self.text2.text?.append(country + " ")
                        }
                }
            }
            
            if let status = json["status"] as? String {
                self.title3.text = "Status"
                self.text3.text = status
            }
            
            
            
        }
        
        
        
        AF.request("https://api.themoviedb.org/3/tv/\(id)/credits?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en-US").responseJSON { (response) in
            
            print("Request - \(response.request)")
            
            guard let json = response.result.value as? [String: Any],
                let cast = json["cast"] as? [Dictionary<String, Any>],
                let crew = json["crew"] as? [Dictionary<String, Any>] else {
                    print("error")
                    return
            }
            //
            //            cast.sort(by: { (person1, person2) -> Bool in
            //                let order1 = person1["order"] as! Int
            //                let order2 = person2["order"] as! Int
            //                return order1 < order2
            //            })
            
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
                    self.castStackView.addArrangedSubview(actorLabel)
                }
            }
            
            for member in crew {
                guard let job = member["job"] as? String,
                    let name = member["name"] as? String else { return }
                
                switch job {
                case "Director":
                    self.directorLabel.text = name + "\n"
                case "Novel":
                    self.writerLabel.text = name + "\n"
                case "Executive Producer":
                    let producerLabel = UILabel()
                    producerLabel.font = UIFont.systemFont(ofSize: 13.0)
                    producerLabel.textColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
                    producerLabel.text = name
                    self.crewStackView.addArrangedSubview(producerLabel)
                default:
                    ()
                }
            }
            
            if (self.writerLabel.text?.isEmpty)! {
                print("Writer text empty")
                self.writerTitleLabel.removeFromSuperview()
                self.writerLabel.removeFromSuperview()
            }
            
            if let lastCrewElement = self.crewStackView.arrangedSubviews.last as? UILabel {
                if lastCrewElement.text == "Producers" {
                    lastCrewElement.removeFromSuperview()
                }
            }
            
            if (self.directorLabel.text?.isEmpty)! {
                guard let firstCrewElement = self.crewStackView.arrangedSubviews.first as? UILabel else { return }
                firstCrewElement.removeFromSuperview()
            }
            
        }
        
    }
    
    
    private func getTextViewHeight(fromText text: String) -> CGFloat {
        
        let frame = CGRect(x: self.descriptionTextView.frame.origin.x, y: 0, width: self.descriptionTextView.frame.size.width, height: 0)
        let textView = UITextView(frame: frame)
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 14.0)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.sizeToFit()
        
        var textFrame = CGRect()
        textFrame = textView.frame
        
        var size = CGSize()
        size = textFrame.size
        
        size.height = textFrame.size.height
        return size.height
    }


}
