//
//  CastTableViewCell.swift
//  Film App
//
//  Created by Вероника Данилова on 17/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

class CastTableViewCell: UITableViewCell {
    
    @IBOutlet weak var castStackView: UIStackView!
    @IBOutlet weak var crewStackView: UIStackView!
    @IBOutlet weak var actorsTitleLabel: UILabel!
    @IBOutlet weak var directorTitleLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var writerTitleLabel: UILabel!
    @IBOutlet weak var writerLabel: UILabel!
    @IBOutlet weak var producersTitleLabel: UILabel!
    @IBOutlet weak var castStackViewBottom: NSLayoutConstraint!
    
    enum JobTypes {
        case actor
        case producer
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with castData: MovieCast) {
        
        if castData.actors.isEmpty {
            self.actorsTitleLabel.isHidden = true
        } else {
            for actorName in castData.actors {
                createStackViewLabel(ofType: .actor, withText: actorName)
            }
        }
        
        if let director = castData.director {
            self.directorLabel.text = director + "\n"
        } else {
            self.directorTitleLabel.isHidden = true
            self.directorLabel.isHidden = true
        }
        
        if let writer = castData.writer {
            self.writerLabel.text = writer + "\n"
        } else {
            self.writerTitleLabel.isHidden = true
            self.writerLabel.isHidden = true
        }
        
        if castData.producers.isEmpty {
            self.producersTitleLabel.isHidden = true
        } else {
            for producerName in castData.producers {
                createStackViewLabel(ofType: .producer, withText: producerName)
            }
        }
        
        castStackView.layoutIfNeeded()
        crewStackView.layoutIfNeeded()
        
        if actorsTitleLabel.isHidden && directorTitleLabel.isHidden && writerTitleLabel.isHidden && producersTitleLabel.isHidden {
            createStackViewLabel(ofType: .actor, withText: "No information")
        } else {
            if castStackView.frame.height < crewStackView.frame.height {
                castStackViewBottom.constant = crewStackView.frame.height - castStackView.frame.height
            }
        }
        
    }
    
    private func createStackViewLabel(ofType type: JobTypes, withText text: String? = nil) {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
        if let actorName = text {
            label.text = actorName
        }
        
        switch type {
        case .actor:
            self.castStackView.addArrangedSubview(label)
        case .producer:
            self.crewStackView.addArrangedSubview(label)
        }

    }
    

}
