import UIKit
import Kingfisher

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var darkThemeSwitcher: UISwitch!
    @IBOutlet weak var wishlistViewSegmentedControl: UISegmentedControl!
    
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    

}
