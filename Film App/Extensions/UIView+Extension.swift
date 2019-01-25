import UIKit

extension UIView {
    
    func lookupSubview<T: UIView>() -> T? {
        if let value = self as? T {
            return value
        }
        
        for subview in subviews {
            if let x:T = subview.lookupSubview() {
                return x
            }
        }
        
        return nil
    }
    
    func showToast(withText text: String) {
        
        let toast = UIView()
        toast.backgroundColor = .darkGray
        toast.layer.cornerRadius = 10.0
        toast.alpha = 0
        
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
    
}
