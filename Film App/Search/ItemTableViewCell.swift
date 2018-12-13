//
//  ItemTableViewCell.swift
//  Film App
//
//  Created by Вероника Данилова on 13/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellHeaderTitle: UILabel!
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    public var data = [DatabaseObject]()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.moviesCollectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieCell")
        moviesCollectionView.dataSource = self
        moviesCollectionView.delegate = self
        
        moviesCollectionView.reloadData()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension ItemTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCollectionViewCell
        
        cell.configure(with: data[indexPath.item])
        // Configure the cell
        
        return cell
    }
    
}
