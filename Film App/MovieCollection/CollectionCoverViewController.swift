import UIKit
import Kingfisher

class CollectionCoverViewController: UIViewController {
    
    private var data: Data!
    lazy private var coverImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        imageView.backgroundColor = UIColor.black
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        return imageView
    }()
    
    init(data: Data) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coverImageView.image = UIImage(data: data)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut, animations: {
            self.coverImageView.frame.origin = CGPoint(x: -(UIScreen.main.bounds.maxX * 1.5), y: self.coverImageView.frame.origin.y)
            self.coverImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            
            self.coverImageView.layer.opacity = 0.4
        }, completion: { (true) in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
}
