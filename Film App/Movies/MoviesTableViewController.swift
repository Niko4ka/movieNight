//
//  MoviesTableViewController.swift
//  Film App
//
//  Created by Вероника Данилова on 28/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

class MoviesTableViewController: UITableViewController {

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SliderTableViewCell", bundle: nil), forCellReuseIdentifier: "SlideCell")
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SlideCell", for: indexPath) as! SliderTableViewCell
        

        // Configure the cell...

        return cell
    }
 

}
