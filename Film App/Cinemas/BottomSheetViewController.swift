import UIKit
import MapKit

class BottomSheetViewController: UIViewController {

    @IBOutlet weak var holdView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var isOpenedLabel: UILabel!
    @IBOutlet weak var showTheRouteButton: UIButton!
    
    
    var selectedCinema: Cinema!
    let fullView: CGFloat = 100
    var partialView: CGFloat = 500
    
    init(cinema: Cinema) {
        self.selectedCinema = cinema
        super.init(nibName: "BottomSheetViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        view.addGestureRecognizer(gesture)
        
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        holdView.layer.cornerRadius = 3
        roundView.layer.cornerRadius = roundView.frame.width / 2
        showTheRouteButton.layer.cornerRadius = 5
        configure(with: selectedCinema)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabBarController = tabBarController {
            partialView = UIScreen.main.bounds.height - (roundView.frame.maxY + UIApplication.shared.statusBarFrame.height + tabBarController.tabBar.frame.height)
        }
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            let frame = self?.view.frame
            let yComponent = self!.partialView
            self?.view.frame = CGRect(x: 0,
                                      y: yComponent,
                                      width: frame?.width ?? UIScreen.main.bounds.width,
                                      height: frame?.height ?? UIScreen.main.bounds.height)
        }
    }
    
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            let frame = self?.view.frame
            self?.view.frame = CGRect(x: 0,
                                      y: UIScreen.main.bounds.maxY,
                                      width: frame?.width ?? UIScreen.main.bounds.width,
                                      height: frame?.height ?? UIScreen.main.bounds.height)
        }) { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }

    }
    
    @IBAction func showTheRouteButtonTapped(_ sender: UIButton) {
        
        let coordinates = CLLocationCoordinate2D(latitude: selectedCinema.lat, longitude: selectedCinema.lng)
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapitem = MKMapItem(placemark: placemark)
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapitem.openInMaps(launchOptions: options)

    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        
        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            self.view.frame = CGRect(x: 0,
                                     y: y + translation.y,
                                     width: view.frame.width,
                                     height: view.frame.height)
            recognizer.setTranslation(.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration = velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y)
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction], animations: {
                
                if velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0,
                                             y: self.partialView,
                                             width: self.view.frame.width,
                                             height: self.view.frame.height)
                } else {
                    self.view.frame = CGRect(x: 0,
                                             y: self.fullView,
                                             width: self.view.frame.width,
                                             height: self.view.frame.height)
                }
                
            }, completion: nil)
        }
        
    }
    
    private func configure(with cinemaData: Cinema) {
        titleLabel.text = cinemaData.name
        addressLabel.text = cinemaData.address
        if let isOpened = cinemaData.isOpened {
            if isOpened {
                roundView.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                isOpenedLabel.text = "Opened now"
                isOpenedLabel.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            } else {
                roundView.backgroundColor = UIColor.red
                isOpenedLabel.text = "Closed now"
                isOpenedLabel.textColor = UIColor.red
            }
        } else {
            roundView.isHidden = true
            isOpenedLabel.isHidden = true
        }
        
    }
    
    private func prepareBackgroundView() {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let visualEffect = UIVisualEffectView(effect: blurEffect)
        let bluredView = UIVisualEffectView(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        
        view.insertSubview(bluredView, at: 0)
    }

}
