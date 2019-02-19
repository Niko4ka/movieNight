import UIKit

extension UIView {
    
    func showToast(withText text: String) {
                
        let toast = createToast(withText: text)
        self.addSubview(toast)
        
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        toast.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -80.0).isActive = true
        toast.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 64.0).isActive = true

        self.bringSubviewToFront(toast)
        
        UIView.animate(withDuration: 0.2, animations: {
            toast.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 1.6, animations: {
                toast.alpha = 0
            }, completion: { _ in
                toast.removeFromSuperview()
            })
        }
    }
    
    
    
    ///  Returns background view with label
    ///
    /// - Parameter text: Text of the label
    /// - Returns: background view with label
    class func getEmptyView(withText text: String) -> UIView {
        let backgroundView = UIView()
        backgroundView.frame.size = UIScreen.main.bounds.size
        backgroundView.backgroundColor = UIColor.white
        let label = UILabel()
        backgroundView.addSubview(label)
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = #colorLiteral(red: 0.4352941215, green: 0.4431372583, blue: 0.4745098054, alpha: 1)
        label.textAlignment = .center
        
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -0.15 * backgroundView.frame.height).isActive = true
        label.widthAnchor.constraint(equalToConstant: backgroundView.frame.width - 32).isActive = true
        return backgroundView
    }
    
    // Private
    
    private func createToast(withText text: String) -> UIView {
        
        let toast = UIView()
        toast.backgroundColor = .darkGray
        toast.layer.cornerRadius = 10.0
        toast.alpha = 0
        toast.restorationIdentifier = "toastView"
        
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = .white
        
        toast.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: toast.topAnchor, constant: 8.0).isActive = true
        label.bottomAnchor.constraint(equalTo: toast.bottomAnchor, constant: -8.0).isActive = true
        label.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 8.0).isActive = true
        label.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -8.0).isActive = true
        
        return toast
    }
    
}
