import UIKit

protocol KeywordsViewControllerDelegate: AnyObject {
    func keywordsViewController(_ src: KeywordsViewController, didSelect keyword: SearchKeyword)
}

class KeywordsViewController: UITableViewController {
    
    var results = [SearchKeyword]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    weak var delegate: KeywordsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
    }
    
    func keyword(at indexPath: IndexPath) -> SearchKeyword {
        return results[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = keyword(at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.keywordsViewController(self, didSelect: keyword(at: indexPath))
    }
}
