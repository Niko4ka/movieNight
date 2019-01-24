import UIKit

protocol ExpandableHeaderViewDelegate: class {
    func toggleSection(header: ExpandableHeaderView, section: Int)
    func showGenreList(genre: (id: Int, name: String))
}

class ExpandableHeaderView: UITableViewHeaderFooterView {
    
    var delegate: ExpandableHeaderViewDelegate?
    var section: Int?
    var seeAllButton: UIButton!
    var genre: (id: Int, name: String)?
    
    func setup(genre: (id: Int, name: String), section: Int, delegate: ExpandableHeaderViewDelegate) {
        
        self.delegate = delegate
        self.section = section
        self.genre = genre
        self.textLabel?.text = genre.name
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.textColor = .white
        contentView.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.1294117719, blue: 0.1411764771, alpha: 1)
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
