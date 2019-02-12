import UIKit
import MapKit
import CoreLocation

class CinemasMapViewController: UIViewController {

    var map: MKMapView!
    var locationManager: CLLocationManager!
    var nearCinemas = [Cinema]()
    var bottomSheet: BottomSheetViewController?
    let exampleCinema = Cinema(address: "103 Orchard St, New York, NY 10002, США", name: "New Your Central Cinema", isOpened: true, lat: 59.9314393, lng: 30.3574075)
    
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
    
    /// Shows bottom sheet view with detail information
    ///
    /// - Parameter cinema: Cinema object of selected annotation view
    private func addBottomSheetView(withCinema cinema: Cinema) {
        
        let bottomSheetVC = BottomSheetViewController(cinema: cinema)
        addChild(bottomSheetVC)
        view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        let height = view.frame.height
        let width = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0,
                                          y: view.frame.maxY,
                                          width: width,
                                          height: height)
        bottomSheet = bottomSheetVC
    }

}

extension CinemasMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: center, span: span)
        map.setRegion(region, animated: false)
        
        // For test
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = CLLocationCoordinate2D(latitude: exampleCinema.lat, longitude: exampleCinema.lng)
//        annotation.title = exampleCinema.name
//        self.map.addAnnotation(annotation)
        
        
        Client.shared.searchCinemas(lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude) { (cinemas) in
            
            guard let cinemas = cinemas else { return }
            self.nearCinemas = cinemas
        // TODO: Показывать алерт
            for cinema in cinemas {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: cinema.lat, longitude: cinema.lng)
                annotation.title = cinema.name
                self.map.addAnnotation(annotation)
            }
        }
    }
}

extension CinemasMapViewController: MKMapViewDelegate {

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let anntotationCoordinates = view.annotation?.coordinate else { return }

        let lat = anntotationCoordinates.latitude
        let lng = anntotationCoordinates.longitude

        guard let selectedCinema = nearCinemas.filter({ $0.lat == lat && $0.lng == lng}).first else { return }

        if bottomSheet != nil {
            bottomSheet!.view.removeFromSuperview()
            bottomSheet!.removeFromParent()
            bottomSheet = nil
        }
        
        // For test
//        addBottomSheetView(withCinema: exampleCinema)
        
        addBottomSheetView(withCinema: selectedCinema)
    }
}
