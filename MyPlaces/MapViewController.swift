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
    let regionInMeters = 10_000.00
    var incomeSegueIdentifier = ""
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var adressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func doneButtonPressed() {
        
    }
    
    private func setupMapView() {
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            // скрываем лишнее если переход через showPlace
            mapPinImage.isHidden = true
            adressLabel.isHidden = true
            doneButton.isHidden = true
        }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    massage: "To enable it go: Settings -> Privacy -> Location Services and turn On")
            }
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
            if incomeSegueIdentifier == "getAdress" { showUserLocation() }
            break
        case .denied:
            // Show alert controller
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    massage: "To enable it go: Settings -> Privacy -> Location Services and turn On")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show alert controller
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    massage: "To enable it go: Settings -> Privacy -> Location Services and turn On")
            }
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
    
    // вызов AlertController
    private func showAlert(title: String, massage: String) {
        let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
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
