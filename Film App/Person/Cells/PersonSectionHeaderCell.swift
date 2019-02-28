import UIKit

class PersonSectionHeaderCell: UITableViewCell {
    
    weak var colorDelegate: ColorThemeCellObserver! {
        didSet {
            setColorTheme()
        }
    }

    @IBOutlet weak var sectionLabel: UILabel!
    
    private func setColorTheme() {
        if colorDelegate.isDarkTheme {
            contentView.backgroundColor = .lightBlueTint
            sectionLabel.textColor = .darkText
        } else {
            contentView.backgroundColor = UIColor.groupTableViewBackground
            sectionLabel.textColor = .lightGray
        }
    }

}
