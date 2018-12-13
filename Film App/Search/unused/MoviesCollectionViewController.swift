//
//  MoviesCollectionViewController.swift
//  Film App
//
//  Created by Вероника Данилова on 11/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MovieCell"

class MoviesCollectionViewController: UICollectionViewController {
    
    public var data = [DatabaseObject]()
//    let collectionViewFooterReuseIdentifier = "footer"
//    let collectionViewHeaderReuseIdentifier = "header"
    
    init(withData data: [DatabaseObject]) {
        self.data = data
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        flowLayout.itemSize = CGSize(width: 100.0, height: 210.0)
//        flowLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 30.0)

        super.init(collectionViewLayout: flowLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
//        self.collectionView.register(UINib(nibName: "HeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionViewHeaderReuseIdentifier)
//
    }



    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return data.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MovieCollectionViewCell
    
        cell.configure(with: data[indexPath.item])
        // Configure the cell
    
        return cell
    }
    
//    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        
//        print("Header in coll view")
//        
//        switch kind {
//        case UICollectionView.elementKindSectionHeader:
//            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: collectionViewHeaderReuseIdentifier, for: indexPath) as! HeaderCollectionReusableView
//            header.headerTitle.text = "This is header"
//            print("Header - \(header.frame.width)")
//            return header
//        default:
//            assert(false)
//        }
        
//        if kind == UICollectionView.elementKindSectionHeader {
//
//        }
        
//        else {
//            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 3.0)
//            let footer = UICollectionReusableView(frame: frame)
//            print("Header - \(footer.frame.width)")
//            return footer
//        }
        
//    }
    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: UIScreen.main.bounds.width, height: 30.0)
//    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
}
