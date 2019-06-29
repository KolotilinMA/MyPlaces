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

class MapViewController: UIViewController {
    
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupPlacemark()
        checkLocationServises()
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true, completion: nil)
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
            checkLocationAuthtorization()
        } else {
            // Show alert controller
        }
    }
    
    // настройка точности геопозиции
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // проверка статуса геопозиции
    private func checkLocationAuthtorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        case .denied:
            // Show alert controller
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show alert controller
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
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
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50 ))
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
}

// проверка изменения статуса авторизации
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthtorization()
    }
}
