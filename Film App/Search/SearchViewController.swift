//
//  SearchViewController.swift
//  Film App
//
//  Created by Вероника Данилова on 11/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class SearchViewController: UIViewController {
    
    @IBOutlet weak var keywordsTableView: UITableView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var childControllersStackView: UIStackView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var keywordResults = [String]()
    var databaseResults = [DatabaseObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.titleView = self.searchController.searchBar
        definesPresentationContext = true
        
        keywordsTableView.delegate = self
        keywordsTableView.dataSource = self
        keywordsTableView.isHidden = true
        
    }
    
    private func keywordsRequest(forKey key: String) {
        
        keywordResults.removeAll()
        
        guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        AF.request("https://api.themoviedb.org/3/search/keyword?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&query=\(encodedKey)&page=1").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    print(" --- 1 ---- error")
                    return
            }
            
            for result in dictionary {
                let keyword = result["name"] as! String
                self.keywordResults.append(keyword)
            }
            
            if self.keywordResults.isEmpty {
                self.keywordsTableView.isHidden = true
                self.hintLabel.isHidden = true
            } else {
                self.keywordsTableView.isHidden = false
            }
            
            self.keywordsTableView.reloadData()
        }
    }
    
    private func showSearchResult(forKey key: String) {
        
        keywordsTableView.isHidden = true
        hintLabel.isHidden = true

        guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        AF.request("https://api.themoviedb.org/3/search/multi?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en&query=\(encodedKey)&page=1&include_adult=false").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    print(" --- 2 ---- error")
                    return
            }
            
            for object in dictionary {
                if let databaseObject = DatabaseObject(fromJson: object) {
                    self.databaseResults.append(databaseObject)
                }
            }
            
            let childVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsTableViewController
            childVC.data = self.databaseResults

            childVC.view.frame.size = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
            self.addChild(childVC)
            self.view.addSubview(childVC.view)
            childVC.didMove(toParent: self)


            
        
//            let childVC = MoviesCollectionViewController(withData: self.databaseResults)
//            childVC.view.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 220.0)
//            
//            self.addChild(childVC)
//            self.childControllersStackView.addSubview(childVC.view)
//            childVC.didMove(toParent: self)

        }
    }
    
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return keywordResults.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "KeywordCell", for: indexPath)
            cell.textLabel?.text = keywordResults[indexPath.row]
            return cell
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            let cell = tableView.cellForRow(at: indexPath)
            guard let selectedKeyword = cell?.textLabel?.text else { return }
            showSearchResult(forKey: selectedKeyword)

    }
}


extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {

        guard let searchText = searchController.searchBar.text else { return }
        
        if searchText.count < 3  {
            keywordResults.removeAll()
            keywordsTableView.reloadData()
            keywordsTableView.isHidden = true
            hintLabel.isHidden = false
        } else {
            keywordsRequest(forKey: searchText)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search button clicked")
        guard let searchText = searchBar.text else { return }
        showSearchResult(forKey: searchText)
    }
}
