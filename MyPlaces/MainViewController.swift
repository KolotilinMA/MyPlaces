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
    let places = Place.getPlaces()
    
    
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
       
        // Приминение name ячейки из массива places
        cell.NameLabel?.text = places[indexPath.row].name
        // Приминение location ячейки из массива places
        cell.locationLabel.text = places[indexPath.row].location
        // Приминение type ячейки из массива places
        cell.typeLabel.text = places[indexPath.row].type
        // Приминение image ячейки из массива places по имени
        cell.imageOfPlace?.image = UIImage(named: places[indexPath.row].image)
        // Скругляем imageOfPlace на радиус половины высоты imageOfPlace
        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        // Обрезаем скругление у imageOfPlace
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

    @IBAction func cancelAction(_ seque: UIStoryboardSegue) {
        // Выход по кнопке cancel на главный экран
    }
    
}
