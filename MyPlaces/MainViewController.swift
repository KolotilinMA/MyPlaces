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
    
    // создаем searchController (nil - работаем в текущем Controller)
    private let searchController = UISearchController(searchResultsController: nil)
    // Создаем массив мест из БД
    private var places: Results<Place>!
    // Массив для поиска
    private var filteredPlaces: Results<Place>!
    // значение для сортировки
    private var ascendingSorting = true
    // переменная указывающая на заполнение SearchBar
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    //
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var reverseSortingButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Подгружаем БД
        places = realm.objects(Place.self)
        // Настройка Search Controller
        //
        // результаты поиска будут в текущем Controller
        searchController.searchResultsUpdater = self
        // разрешаем работать с найденым контентом
        searchController.obscuresBackgroundDuringPresentation = false
        // присваиваем название
        searchController.searchBar.placeholder = "Search"
        // встраиваем SearchController в NavigationBar
        navigationItem.searchController = searchController
        // позволяем отпустить searchController при переходе
        definesPresentationContext = true
    }

    // MARK: - Table view data source

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            // возвращаем если фильтруем
            return filteredPlaces.count
        }
        // Возвращаем количество ячеек из массива places если БД пустая то 0
        return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var place = Place()
        if isFiltering {
            place = filteredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
        
        

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
            let place: Place
            if isFiltering {
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
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
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reveredSorting(_ sender: Any) {
        // меняем сортировку
        ascendingSorting.toggle()
        // Замена иконки сортировки
        if ascendingSorting {
            reverseSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reverseSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        sorting()
    }
    
    private func sorting() {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            // сортируем по имени с учетом направления (ascendingSorting)
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            // сортируем по дате с учетом направления (ascendingSorting)
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        // обновляем tableView
        tableView.reloadData()
    }
    
}


extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        // фильтруем в имени и месту
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}
