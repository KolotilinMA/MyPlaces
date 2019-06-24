//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Михаил on 25/06/2019.
//  Copyright © 2019 Михаил. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // замена пустого TableView на пустой View
        tableView.tableFooterView = UIView()
    }

    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // создание UIAlertController actionSheet
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            // создание кнопки Camera
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                // вызаваем chooseImagePicker с параметром camera
                self.chooseImagePicker(sourse: .camera)
            
            }
            // создание кнопки Photo
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                // вызаваем chooseImagePicker с параметром photoLibrary
                self.chooseImagePicker(sourse: .photoLibrary)
                
            }
            // создание кнопки Cancel
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            // добавление кнопок к actionSheet
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            // вызов actionSheet
            present(actionSheet, animated: true, completion: nil)
        } else {
            // убираем клавиатуру если ячейка не 0
            view.endEditing(true)
        }
    }
    
    
}

// MARK: Text field delegate

extension NewPlaceViewController: UITextFieldDelegate {
    
    // Скрываем клавиатуру по нажатию Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: Работа с изображениеми
extension NewPlaceViewController {
    
    func chooseImagePicker(sourse: UIImagePickerController.SourceType) {
        // проверка доступности источника выбора фото
        if UIImagePickerController.isSourceTypeAvailable(sourse) {
            
            let imagePicker = UIImagePickerController()
            // разрешаем редактировать фото
            imagePicker.allowsEditing = true
            // определяем тип источника изображения
            imagePicker.sourceType = sourse
            // отображаем imagePicker
            present(imagePicker, animated: true, completion: nil)
        }
    }
}

