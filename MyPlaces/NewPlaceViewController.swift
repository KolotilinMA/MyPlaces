//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Михаил on 25/06/2019.
//  Copyright © 2019 Михаил. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    var imageIsChanged = false
    
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeType: UITextField!
    @IBOutlet var ratingControl: RatingControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // замена пустого TableView на пустой View
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        // Отключение кнопки save по умолсанию
        saveButton.isEnabled = false
        // срабатование метода при редактировании placeName
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        // если редактирум то работает эта функция
        setupEditScreen()
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
    
    func savePlace() {
        
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
                             imageData: imageData,
                             rating: Double(ratingControl.rating))
        
        // если редактируем то присваиваем данные
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
            // Сохраняем данные в БД
            StorageManager.saveObject(newPlace)
        }
        
        
    }
    
    // Функция для работы с редакрированной ячейкой
    private func setupEditScreen() {
        // работаем если currentPlace чем то заполнен
        if currentPlace != nil {
            // настраиваем NavigatorBar
            setupNavigatorBar()
            // отмена изображения по умолчанию
            imageIsChanged = true
            // конвертируем image из imageData в UIImage
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            // заполняем поля NewPlaceViewController
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill // с параметром AspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            ratingControl.rating = Int(currentPlace.rating)
        }
    }
    
    // настройка NavigatorBar
    private func setupNavigatorBar() {
        // исправляем UIBarButtonItem на ""
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        // убираем leftBarButtonItem
        navigationItem.leftBarButtonItem = nil
        // присваевываем в заголовок name
        title = currentPlace?.name
        // включаем saveButton
        saveButton.isEnabled = true
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

