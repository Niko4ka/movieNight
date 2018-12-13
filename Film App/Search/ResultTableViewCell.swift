//
//  ItemTableViewCell.swift
//  Film App
//
//  Created by Вероника Данилова on 13/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    
    public var data = [DatabaseObject]()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.itemsCollectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
        
        itemsCollectionView.reloadData()

    }


}

extension ResultTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCollectionViewCell
        
        cell.configure(with: data[indexPath.item])
        // Configure the cell
        
        return cell
    }
    
}
