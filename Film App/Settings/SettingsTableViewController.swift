import UIKit
import Kingfisher

class SettingsTableViewController: UITableViewController, ColorThemeObserver {
    
    @IBOutlet weak var darkThemeSwitcher: UISwitch!
    @IBOutlet weak var wishlistViewSegmentedControl: UISegmentedControl!
    
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addColorThemeObservers()
        checkCurrentColorTheme()
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
    
    @IBAction func wishlistViewSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            userDefaults.set("list", forKey: "wishlistView")
        } else {
            userDefaults.set("collection", forKey: "wishlistView")
        }
    }
    
    func darkThemeEnabled() {
        print("Dark theme in settings")
        if !darkThemeSwitcher.isOn {
            darkThemeSwitcher.setOn(true, animated: false)
        }
        tableView.backgroundColor = 
    }

    func darkThemeDisabled() {
        print("Light theme in settings")
        if darkThemeSwitcher.isOn {
            darkThemeSwitcher.setOn(false, animated: false)
        }
    }

}
