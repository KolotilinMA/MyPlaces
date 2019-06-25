//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Михаил on 24/06/2019.
//  Copyright © 2019 Михаил. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    // Создаем массив мест
    var places = Place.getPlaces()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Возвращаем количество ячеек из массива places
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let place = places[indexPath.row]
        
        // Приминение name ячейки из массива places
        cell.NameLabel?.text = place.name
        // Приминение location ячейки из массива places
        cell.locationLabel.text = place.location
        // Приминение type ячейки из массива places
        cell.typeLabel.text = place.type
        
        if place.image == nil {
            // Приминение image ячейки из массива places по имени
            cell.imageOfPlace?.image = UIImage(named: place.restaurantImage!)
        } else {
            // риминение image ячейки из массива places
            cell.imageOfPlace.image = place.image
        }
        
        // Скругляем placeImage на радиус половины высоты placeImage
        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        // Обрезаем скругление у placeImage
        cell.imageOfPlace?.clipsToBounds = true
        
        return cell
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func unwindSegue(_ seque: UIStoryboardSegue) {
        // извлекакем новые данные
        guard let newPlaceVC = seque.source as? NewPlaceViewController else { return }
        // присваиваем новые данные в newPlaceVC
        newPlaceVC.saveNewPlace()
        // добавляем новые данные в массив places
        places.append(newPlaceVC.newPlace!)
        // обновляем tableView
        tableView.reloadData()
    }
    
}
