//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Михаил on 29/06/2019.
//  Copyright © 2019 Михаил. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}


class MapViewController: UIViewController {
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 1_000.00
    var incomeSegueIdentifier = ""
    var placeCoordinate: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []
    var previousLocation: CLLocation? {
        didSet {
            startTracingUserLocation()
        }
    }
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
        checkLocationServises()
    }
    
    // Функция в кнопке центрует положение пользователя с удалением regionInMeters
    @IBAction func centerViewInUserLocation() {
        showUserLocation()
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goButtonPressed() {
        getDirections()
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        goButton.isHidden = true
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            // скрываем лишнее если переход через showPlace
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    private func resetMapView(withNew directions: MKDirections) {
        // удаляем все наложения на карте
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        // отменяем все маршруты в массиве
        let _ = directionsArray.map { $0.cancel() }
        // удаляем все маршруты из массива
        directionsArray.removeAll()
    }
    
    private func setupPlacemark() {
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        // преобразоваваем из адреса в координаты
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            // проверяем на наличие ошибок
            if let error = error {
                print(error)
                return
            }
            // создаем и проверяем наличие placemarks
            guard let placemarks = placemarks else { return }
            // создаем placemark из первого placemarks
            let placemark = placemarks.first
            // создаем аннотацию
            let annotation = MKPointAnnotation()
            // вводим описание аннотации
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            // выбираем точку на карте
            guard let placemarkLocation = placemark?.location else { return }
            //присваевыем координаты из placemark в аннотацию
            annotation.coordinate = placemarkLocation.coordinate
            //
            self.placeCoordinate = placemarkLocation.coordinate
            // показываем на карте все annotation
            self.mapView.showAnnotations([annotation], animated: true)
            // выделить annotation
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    // проверка служб геолокаций
    private func checkLocationServises() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert controller
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn On")
            }
        }
    }
    
    // настройка точности геопозиции
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // проверка статуса геопозиции
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
            break
        case .denied:
            // Show alert controller
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Your Location is not Available",
                    message: "To give permission Go to: Setting -> MyPlaces -> Location")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // центруем карту на позиции пользователя
    private func startTracingUserLocation() {
        // координаты пользователя
        guard let previousLocation = previousLocation else { return }
        // координаты центра карты
        let center = getCenterLocation(for: mapView)
        // проверка разницы растояний
        guard center.distance(from: previousLocation) > 50 else { return }
        // обновляем координаты на новые
        self.previousLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // показываем с задержкой
            self.showUserLocation()
        }
    }
    
    private func getDirections() {
        // проверка на наличие начальной точки
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        // включение режима постоянного отслеживание положения пользователя
        locationManager.startUpdatingLocation()
        // присваиваем координаты
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        // проверка на наличие точки назначения
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        // создание маршрута
        let directions = MKDirections(request: request)
        // удаляем все старые маршруты
        resetMapView(withNew: directions)
        // построение маршрута
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Directions is not found")
                return
            }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distanse = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distanse) км.")
                print("Время в пути составит: \(timeInterval) сек.")
            }
        }
    }
    
    private func createDirectionsRequest (from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let distinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let distination = MKPlacemark(coordinate: distinationCoordinate)
        
        let request = MKDirections.Request()
        // точки старта и назначения
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: distination)
        // выбор типа навигации
        request.transportType = .automobile
        // показывает альтернативные маршруты
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // вызов AlertController
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // проверка что annotation не наша точка
        guard !(annotation is MKUserLocation) else { return nil }
        // создаем annotationView с Pin
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        // вызываем annotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        // создаем image
        if let imageData = place.imageData {
            // создаем и задаем размеры image
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            // скругляем и обрезаем
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            // конвертируем в UIImage
            imageView.image = UIImage(data: imageData)
            // вставляем imageView в annotationView
            annotationView?.rightCalloutAccessoryView = imageView
            
        }
        
        return annotationView
    }
    
    // вызывается при смене региона отображаемой карты
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                // показываем с задержкой
                self.showUserLocation()
            }
        }
        // отмена отложенного запроса
        geocoder.cancelGeocode()
        
        // декодирует координаты в массив мест с возможной ошибкой
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    // отображение маршрута на карте
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        // выбор цвета отображения на карте
        renderer.strokeColor = .blue
        
        return renderer
    }
}

// проверка изменения статуса авторизации
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
