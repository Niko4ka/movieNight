import UIKit
import MapKit
import CoreLocation

class CinemasMapViewController: UIViewController {

    var map: MKMapView!
    var locationManager: CLLocationManager!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        let frame = CGRect(origin: self.view.frame.origin, size: self.view.frame.size)
        self.map = MKMapView(frame: frame)
        self.map.showsUserLocation = true
        self.map.delegate = self
        self.view.addSubview(map)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        determineUserLocation()
    }
    
    private func determineUserLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

}

extension CinemasMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        manager.stopUpdatingLocation()
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: center, span: span)
        map.setRegion(region, animated: false)
        
        // TODO: Сохранять пользовательское местоположение в юзер дефолтс
        
        Client.shared.searchCinemas(lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude) { (cinemas) in
            
            guard let cinemas = cinemas else { return }
        // TODO: Показывать алерт
            for cinema in cinemas {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: cinema.lat, longitude: cinema.lng)
                annotation.title = cinema.name
                self.map.addAnnotation(annotation)
            }
        // TODO: Добавить доп/инфо
        }
    }
}

extension CinemasMapViewController: MKMapViewDelegate {

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Tap")
        print("\(view.annotation?.title)")
        let modalViewController = ModalViewController()
        let transitioningDelegate = HalfModalTransitioningDelegate(presentingViewController: self, presentedViewController: modalViewController)
    
        modalViewController.modalPresentationStyle = .custom
        modalViewController.transitioningDelegate = transitioningDelegate
        present(modalViewController, animated: true, completion: nil)
        
    }
}
