//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Михаил on 24/06/2019.
//  Copyright © 2019 Михаил. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    // Создаем массив мест из БД
    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Подгружаем БД
        places = realm.objects(Place.self)
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Возвращаем количество ячеек из массива places если БД пустая то 0
        return places.isEmpty ? 0 : places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let place = places[indexPath.row]

        // Приминение name ячейки из массива places
        cell.nameLabel.text = place.name
        // Приминение location ячейки из массива places
        cell.locationLabel.text = place.location
        // Приминение type ячейки из массива places
        cell.typeLabel.text = place.type
        // Приминение image ячейки из массива places
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

        // Скругляем placeImage на радиус половины высоты placeImage
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        // Обрезаем скругление у placeImage
        cell.imageOfPlace.clipsToBounds = true

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

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        // извлекакем новые данные
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        // присваиваем новые данные в newPlaceVC
        newPlaceVC.saveNewPlace()
        // обновляем tableView
        tableView.reloadData()
    }
    
}
