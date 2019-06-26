//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Михаил on 25/06/2019.
//  Copyright © 2019 Михаил. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    var imageIsChanged = false
    
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeType: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // замена пустого TableView на пустой View
        tableView.tableFooterView = UIView()
        // Отключение кнопки save по умолсанию
        saveButton.isEnabled = false
        // срабатование метода при редактировании placeName
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }

    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // создаем иконки для actionSheet
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            // создание UIAlertController actionSheet
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            // создание кнопки Camera
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                // вызаваем chooseImagePicker с параметром camera
                self.chooseImagePicker(sourse: .camera)
            }
            // вставляем cameraIcon в меню camera
            camera.setValue(cameraIcon, forKey: "image")
            // выравнивание текста actionSheet слева
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            // создание кнопки Photo
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                // вызаваем chooseImagePicker с параметром photoLibrary
                self.chooseImagePicker(sourse: .photoLibrary)
            }
            // вставляем photoIcon в меню photo
            photo.setValue(photoIcon, forKey: "image")
            // выравнивание текста actionSheet слева
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
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
    
    func saveNewPlace() {
        
        // Выбор image по умолчанию или нет
        var image: UIImage?
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        // Конвертируем данные из UIImage в pngData
        let imageData = image?.pngData()
        
        // Сохраняем введеные даные
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData)
        
        // Сохраняем данные в БД
        StorageManager.saveObject(newPlace)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        // закрытие NewPlaceViewController
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: Text field delegate

extension NewPlaceViewController: UITextFieldDelegate {
    
    // Скрываем клавиатуру по нажатию Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // переключение saveButton
    @objc private func textFieldChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
}

// MARK: Работа с изображениеми
extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(sourse: UIImagePickerController.SourceType) {
        // проверка доступности источника выбора фото
        if UIImagePickerController.isSourceTypeAvailable(sourse) {
            
            let imagePicker = UIImagePickerController()
            // объявляем делегатом imagePicker
            imagePicker.delegate = self
            // разрешаем редактировать фото
            imagePicker.allowsEditing = true
            // определяем тип источника изображения
            imagePicker.sourceType = sourse
            // отображаем imagePicker
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Присваиваем отредактированное изображение в imageOfPlace
        placeImage.image = info[.editedImage] as? UIImage
        // позволяем масштабировать изображение
        placeImage.contentMode = .scaleAspectFill
        // Обрезаем по границе
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        // закрываем PickerController
        dismiss(animated: true, completion: nil)
        
    }
    
}

