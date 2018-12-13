//
//  ResultsTableViewController.swift
//  Film App
//
//  Created by Вероника Данилова on 12/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

class ResultsTableViewController: UITableViewController {
    
    public var data = [DatabaseObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        print("Results - \(data.count)")
       
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTableViewCell
        cell.cellHeaderTitle.text = "Ячейка \(indexPath)"
        cell.data = self.data
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }


}


