//
//  MapManager.swift
//  MyPlaces
//
//  Created by Михаил on 30/06/2019.
//  Copyright © 2019 Михаил. All rights reserved.
//

import UIKit
import MapKit

class MapManager {
    
        let locationManager = CLLocationManager()
        private var placeCoordinate: CLLocationCoordinate2D?
        private let regionInMeters = 1_000.00
        private var directionsArray: [MKDirections] = []
    
    // Маркер заведения
    func setupPlacemark(place: Place, mapView: MKMapView) {
        
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
            annotation.title = place.name
            annotation.subtitle = place.type
            // выбираем точку на карте
            guard let placemarkLocation = placemark?.location else { return }
            //присваевыем координаты из placemark в аннотацию
            annotation.coordinate = placemarkLocation.coordinate
            //
            self.placeCoordinate = placemarkLocation.coordinate
            // показываем на карте все annotation
            mapView.showAnnotations([annotation], animated: true)
            // выделить annotation
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // Проверка доступности служб геолокаций
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            // Show alert controller
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn On")
            }
        }
    }
    
    // Проверка авторизации прилоежния для исопользования сервисов геолокации
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
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
    
    // Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Строим маршрут от местоположения пользователя до заведения
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        // проверка на наличие начальной точки
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        // включение режима постоянного отслеживание положения пользователя
        locationManager.startUpdatingLocation()
        // присваиваем координаты
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        // проверка на наличие точки назначения
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        // создание маршрута
        let directions = MKDirections(request: request)
        // удаляем все старые маршруты
        resetMapView(withNew: directions, mapView: mapView)
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
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distanse = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distanse) км.")
                print("Время в пути составит: \(timeInterval) сек.")
            }
        }
    }
    
    // Настройка запроса для расчета маршрута
    func createDirectionsRequest (from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
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
    
    // Меняем отображаемую зону области карты в соответствии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        // координаты пользователя
        guard let location = location else { return }
        // координаты центра карты
        let center = getCenterLocation(for: mapView)
        // проверка разницы растояний
        guard center.distance(from: location) > 50 else { return }
        // обновляем координаты на новые и центруем
        closure(center)
    }
    
    // Сброс всех ранее построенных маршрутов перед построением нового
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        // удаляем все наложения на карте
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        // отменяем все маршруты в массиве
        let _ = directionsArray.map { $0.cancel() }
        // удаляем все маршруты из массива
        directionsArray.removeAll()
    }
    
    // Определение центра отображаемой области карты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Вызов AlertController
    private func showAlert(title: String, message: String) {
        // создаем AlertController
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // создаем кнопку AlertController
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        // вставляем кнопку в AlertController
        alert.addAction(okAction)
        // создаем окно
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        // инициализируем как UIViewController
        alertWindow.rootViewController = UIViewController()
        // определ]ем поверх всех окон
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        // делаем видимым
        alertWindow.makeKeyAndVisible()
        // показываем AlertController
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
