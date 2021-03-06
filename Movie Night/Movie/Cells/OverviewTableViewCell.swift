import UIKit

class OverviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var showMoreButton: UIButton!
    
    weak var colorDelegate: ColorThemeCellObserver! {
        didSet {
            setColorTheme()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
        descriptionTextView.textContainerInset = .zero
        descriptionTextView.textContainer.lineFragmentPadding = 0
    }
    
    
    @IBAction func showMoreButtonPressed() {
        let height = getTextViewHeight(fromText: descriptionTextView.text)
        descriptionHeight.constant = height
        self.contentView.layoutIfNeeded()
        showMoreButton.isHidden = true
        descriptionBottomConstraint.constant = 8.0
        
        if let tableView = self.superview as? UITableView {
            tableView.reloadData()
        }
    }
    
    public func configure(with movie: MovieDetails) {
        
        self.descriptionTextView.text = !movie.description.isEmpty ? movie.description : "No overview"

        let height = self.getTextViewHeight(fromText: self.descriptionTextView.text)
        if height <= self.descriptionHeight.constant {
            self.descriptionHeight.constant = height
            self.showMoreButton.isHidden = true
            self.descriptionBottomConstraint.constant = 8.0
        }
    }
    
    private func getTextViewHeight(fromText text: String) -> CGFloat {
        
        let frame = CGRect(x: descriptionTextView.frame.origin.x, y: 0, width: descriptionTextView.frame.size.width, height: 0)
        let textView = UITextView(frame: frame)
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 14.0)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.sizeToFit()
        
        var textFrame = CGRect()
        textFrame = textView.frame
        
        var size = CGSize()
        size = textFrame.size
        
        size.height = textFrame.size.height
        return size.height
    }
    
    private func setColorTheme() {
        
        if colorDelegate.isDarkTheme {
            descriptionTextView.textColor = .lightText
            descriptionTextView.backgroundColor = .darkThemeBackground
            titleLabel.textColor = .white
            showMoreButton.setTitleColor(.lightBlueTint, for: .normal)
            backgroundColor = .darkThemeBackground
        } else {
            descriptionTextView.textColor = .darkGray
            descriptionTextView.backgroundColor = .white
            showMoreButton.setTitleColor(.defaultBlueTint, for: .normal)
            titleLabel.textColor = .darkText
            backgroundColor = .white
        } 
    }
    
}
