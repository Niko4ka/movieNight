import UIKit

class ReviewTableViewCell: UITableViewCell {
    
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
   

}
