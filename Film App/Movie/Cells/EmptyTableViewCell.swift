import UIKit

class EmptyTableViewCell: UITableViewCell {
    
    weak var colorDelegate: ColorThemeCellObserver! {
        didSet {
            setColorTheme()
        }
    }
    
    @IBOutlet weak var infoLabel: UILabel!
    
    private func setColorTheme() {
        if colorDelegate.isDarkTheme {
            backgroundColor = .darkThemeBackground
            infoLabel.textColor = .white
        } else {
            backgroundColor = .white
            infoLabel.textColor = .darkGray
        }
    }

}
