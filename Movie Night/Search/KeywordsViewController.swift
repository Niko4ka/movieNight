import UIKit

protocol KeywordsViewControllerDelegate: AnyObject {
    func keywordsViewController(_ src: KeywordsViewController, didSelect keyword: SearchKeyword)
}

class KeywordsViewController: UITableViewController {
    
    var isDarkTheme: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    var results = [SearchKeyword]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    weak var delegate: KeywordsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.bounces = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        
    }
    
    func keyword(at indexPath: IndexPath) -> SearchKeyword {
        return results[indexPath.row]
    }
    
    private func setColorThemeFor(cell: UITableViewCell) {
        if isDarkTheme {
            cell.backgroundColor = .darkThemeBackground
            cell.textLabel?.textColor = .white
        } else {
            cell.backgroundColor = .white
            cell.textLabel?.textColor = .darkText
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = keyword(at: indexPath)
        setColorThemeFor(cell: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.keywordsViewController(self, didSelect: keyword(at: indexPath))
    }
}
