//
//  InformationTableViewCell.swift
//  Film App
//
//  Created by Вероника Данилова on 17/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

class InformationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var keysStackView: UIStackView!
    @IBOutlet weak var valuesStackView: UIStackView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func configure(with movie: MovieDetails) {
        
        if keysStackView.subviews.isEmpty && valuesStackView.subviews.isEmpty {
            
            let countries = (key: "Country", value: movie.countries)
            createInfo(from: countries)
            
            let status = (key: "Status", value: movie.status)
            createInfo(from: status)
            
            if let runtimeValue = movie.runtime {
                let runtime = (key: "Runtime", value: "\(runtimeValue) min.")
                createInfo(from: runtime)
            }
            
            if let seasonsNumber = movie.tvShowSeasons {
                let seasons = (key: "Seasons", value: "\(seasonsNumber)")
                createInfo(from: seasons)
            }
            
            keysStackView.layoutIfNeeded()
            valuesStackView.layoutIfNeeded()
        }

    }
    
    private func createInfo(from data: (key: String, value: String)) {
        
        let keyLabel = UILabel()
        keyLabel.font = UIFont.systemFont(ofSize: 13.0)
        keyLabel.textColor = UIColor.black
        keyLabel.text = data.key
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 13.0)
        valueLabel.textColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
        valueLabel.text = data.value
        valueLabel.numberOfLines = 1
        
        keysStackView.addArrangedSubview(keyLabel)
        valuesStackView.addArrangedSubview(valueLabel)
        
    }
    
}
