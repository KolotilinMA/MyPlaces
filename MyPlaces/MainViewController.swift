//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Михаил on 24/06/2019.
//  Copyright © 2019 Михаил. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var tableView: UITableView!
    // Создаем массив мест из БД
    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Подгружаем БД
        places = realm.objects(Place.self)
    }

    // MARK: - Table view data source

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Возвращаем количество ячеек из массива places если БД пустая то 0
        return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    // MARK: Table view delegate
    
    // Функция удаления ячейки
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // объявление ячейки для удаления
        let place = places[indexPath.row]
        // создание действия удаления
        let delitAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            // удаление из БД
            StorageManager.deleteObject(place)
            // удаление из памяти приложения
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [delitAction]
    }
    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // выполняем только если переход showDetail
        if segue.identifier == "showDetail" {
            // создаем indexPath из выбраной ячейки
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            // создаем place из выбраной ячейки
            let place = places[indexPath.row]
            // создаем newPlaceVC на NewPlaceViewController
            let newPlaceVC = segue.destination as! NewPlaceViewController
            // присваиваем newPlaceVC данные из place
            newPlaceVC.currentPlace = place
        }
    }
    

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        // извлекакем новые данные
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        // присваиваем новые данные в newPlaceVC
        newPlaceVC.savePlace()
        // обновляем tableView
        tableView.reloadData()
    }
    
}
