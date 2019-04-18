import UIKit

class InformationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var keysStackView: UIStackView!
    @IBOutlet weak var valuesStackView: UIStackView!
    
    weak var colorDelegate: ColorThemeCellObserver! {
        didSet {
            setColorTheme()
        }
    }

    public func configure(with movie: MovieDetails) {
        
        if keysStackView.subviews.isEmpty && valuesStackView.subviews.isEmpty {
            
            if !movie.countries.isEmpty {
                let countries = (key: "Country", value: movie.countries)
                createInfo(from: countries)
            }
            
            if !movie.status.isEmpty {
                let status = (key: "Status", value: movie.status)
                createInfo(from: status)
            }
            
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
        keyLabel.textColor = UIColor.darkText
        keyLabel.text = data.key
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 13.0)
        valueLabel.textColor = .grayText
        valueLabel.text = data.value
        valueLabel.numberOfLines = 1
        
        keysStackView.addArrangedSubview(keyLabel)
        valuesStackView.addArrangedSubview(valueLabel)
    }
    
    private func setColorTheme() {
        
        var keys = [UILabel]()
        var values = [UILabel]()
        
        for subview in keysStackView.subviews {
            if let label = subview as? UILabel {
                keys.append(label)
            }
        }
        
        for subview in valuesStackView.subviews {
            if let label = subview as? UILabel {
                values.append(label)
            }
        }
        
        if colorDelegate.isDarkTheme {
            titleLabel.textColor = .white
            keys.forEach { $0.textColor = .white }
            values.forEach { $0.textColor = .lightText }
            backgroundColor = .darkThemeBackground
        } else {
            titleLabel.textColor = .darkText
            keys.forEach { $0.textColor = .darkText }
            values.forEach { $0.textColor = .grayText }
            backgroundColor = .white
        }
    }
    
}
