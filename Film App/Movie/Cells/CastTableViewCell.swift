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
    
    var navigator: ProjectNavigator?
    
    enum JobTypes {
        case actor
        case producer
    }

    public func configure(with castData: MovieCast) {
        
        if castData.actors.isEmpty {
            self.actorsTitleLabel.isHidden = true
        } else {
            for actor in castData.actors {
                createStackViewLabel(ofType: .actor, withText: actor.name, id: actor.id)
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
    
    private func createStackViewLabel(ofType type: JobTypes, withText text: String? = nil, id: Int? = nil) {
        
        switch type {
        case .actor:
            let button = UIButton(type: .system)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
            button.contentHorizontalAlignment = .leading
            button.setTitleColor(.grayText, for: .normal)
            if let actorName = text {
                button.setTitle(actorName + " \u{232A}", for: .normal)
            }
            button.heightAnchor.constraint(equalToConstant: 17.0).isActive = true
            if let personId = id {
                button.tag = personId
                button.addTarget(self, action: #selector(showPersonProfile(sender:)), for: .touchUpInside)
            }
            
            self.castStackView.addArrangedSubview(button)
        case .producer:
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 13.0)
            label.textColor = .grayText
            if let actorName = text {
                label.text = actorName
            }
            self.crewStackView.addArrangedSubview(label)
        }

    }
    
    @objc private func showPersonProfile(sender: UIButton) {
        let id = sender.tag
        navigator?.navigate(to: .person(id: id))
    }

}
