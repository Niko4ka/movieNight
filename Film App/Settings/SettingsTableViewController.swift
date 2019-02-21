import UIKit
import Kingfisher

class SettingsTableViewController: UITableViewController, ColorThemeObserver {
    
    @IBOutlet weak var darkThemeSwitcher: UISwitch!
    @IBOutlet weak var listViewCell: UITableViewCell!
    @IBOutlet weak var collectionViewCell: UITableViewCell!
    

    private let userDefaults = UserDefaults.standard
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addColorThemeObservers()
        checkCurrentColorTheme()
        checkCurrentWishlistView()
    }

    @IBAction func darkThemeSwitcherValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            userDefaults.set(true, forKey: "isDarkTheme")
            notificationCenter.post(name: .darkThemeEnabled, object: nil)
        } else {
            userDefaults.set(false, forKey: "isDarkTheme")
            notificationCenter.post(name: .darkThemeDisabled, object: nil)
        }
    }
    
    private func checkCurrentWishlistView() {
        let currentView = UserDefaults.standard.string(forKey: "wishlistView")
        if currentView == "list" {
            listViewCell.accessoryType = .checkmark
        } else {
            collectionViewCell.accessoryType = .checkmark
        }
    }
    
    func darkThemeEnabled() {
        print("Dark theme in settings")
        if !darkThemeSwitcher.isOn {
            darkThemeSwitcher.setOn(true, animated: false)
        }
        tableView.backgroundColor = .darkThemeBackground
    }

    func darkThemeDisabled() {
        print("Light theme in settings")
        if darkThemeSwitcher.isOn {
            darkThemeSwitcher.setOn(false, animated: false)
        }
        tableView.backgroundColor = .groupTableViewBackground
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        switch cell {
        case listViewCell:
            if collectionViewCell.accessoryType == .checkmark {
                collectionViewCell.accessoryType = .none
            }
            cell.accessoryType = .checkmark
            userDefaults.set("list", forKey: "wishlistView")
            notificationCenter.post(name: .listWishlistViewSelected, object: nil)
            
        case collectionViewCell:
            if listViewCell.accessoryType == .checkmark {
                listViewCell.accessoryType = .none
            }
            cell.accessoryType = .checkmark
            userDefaults.set("collection", forKey: "wishlistView")
            notificationCenter.post(name: .collectionWishlistViewSelected, object: nil)
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

}
