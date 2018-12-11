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
    @IBOutlet weak var resultsTableView: UITableView!
    
    
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
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.isHidden = true
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
            
            self.resultsTableView.isHidden = false
            self.resultsTableView.reloadData()

            
            
        }
    }
    
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == keywordsTableView {
            return keywordResults.count
        } else {
            print("database results count - \(databaseResults.count)")
            return databaseResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == keywordsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "KeywordCell", for: indexPath)
            cell.textLabel?.text = keywordResults[indexPath.row]
            return cell
        } else {
            
            let object = databaseResults[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatabaseObjectCell", for: indexPath) as! ResultTableViewCell
            cell.configure(with: object)
            return cell
        }
        
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == keywordsTableView {
            let cell = tableView.cellForRow(at: indexPath)
            guard let selectedKeyword = cell?.textLabel?.text else { return }
            showSearchResult(forKey: selectedKeyword)
        }
        
        
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
