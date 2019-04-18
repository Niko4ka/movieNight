import UIKit

protocol ExpandableHeaderViewDelegate: class {
    func toggleSection(header: ExpandableHeaderView, section: Int)
    func showGenreList(genre: GenreSection)
}

class ExpandableHeaderView: UITableViewHeaderFooterView {
    
    weak var delegate: ExpandableHeaderViewDelegate?
    var section: Int?
    var seeAllButton: UIButton!
    var genre: GenreSection?
    
    func setup(genre: GenreSection, section: Int, delegate: ExpandableHeaderViewDelegate) {
        self.delegate = delegate
        self.section = section
        self.genre = genre
        self.textLabel?.text = genre.name
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let colorDelegate = delegate as? ColorThemeCellObserver {
            if colorDelegate.isDarkTheme {
                textLabel?.textColor = .white
                contentView.backgroundColor = .darkThemeBackground
            } else {
                textLabel?.textColor = .grayText
                contentView.backgroundColor = .groupTableViewBackground
            }
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction))
        addGestureRecognizer(gestureRecognizer)
        addSeeAllButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as! ExpandableHeaderView
        delegate?.toggleSection(header: self, section: cell.section!)
    }
    
    private func addSeeAllButton() {
        seeAllButton = UIButton(type: .system)
        seeAllButton.setTitle("See all >", for: .normal)
        seeAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        seeAllButton.setTitleColor(UIColor.lightGray, for: .normal)
        self.contentView.addSubview(seeAllButton)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        seeAllButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16.0).isActive = true
        seeAllButton.isHidden = true
        seeAllButton.addTarget(self, action: #selector(showGenre), for: .touchUpInside)
    }
    
    @objc func showGenre() {
        if let genre = genre {
            delegate?.showGenreList(genre: genre)
        }
    }
}
