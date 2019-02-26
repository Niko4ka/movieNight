import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    weak var colorDelegate: ColorThemeCellObserver! {
        didSet {
            setColorTheme()
        }
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        reviewTextView.textContainer.lineBreakMode = .byTruncatingTail
        reviewTextView.textContainerInset = .zero
        reviewTextView.textContainer.lineFragmentPadding = 0
    }

    public func configure(with review: MovieReview) {
        userNameLabel.text = review.author
        reviewTextView.text = review.content
    }
   
    private func setColorTheme() {
        if colorDelegate.isDarkTheme {
            backgroundColor = .darkThemeBackground
            userNameLabel.textColor = .white
            reviewTextView.textColor = .lightText
            reviewTextView.backgroundColor = .darkThemeBackground
        } else {
            backgroundColor = .white
            userNameLabel.textColor = .darkText
            reviewTextView.textColor = .darkGray
            reviewTextView.backgroundColor = .white
        }
    }

}
