//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Михаил on 28/06/2019.
//  Copyright © 2019 Михаил. All rights reserved.
//

import UIKit

// @IBDesignable можно добавить есть хочется видеть изменения кода в storyboard
@IBDesignable class RatingControl: UIStackView {
    
    // MARK: Properties
    
    var rating = 0
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }

    // MARK: Button Action
    
    @objc func ratingButtonTapped(button: UIButton) {
        print("Button pressed")
    }
    
    // MARK: Privete Methods
    
    private func setupButtons() {
        // очищаем storyboard
        for button in ratingButtons {
            // удаляем из споска SubView
            removeArrangedSubview(button)
            // удаляем из StackView
            button.removeFromSuperview()
        }

        // Очищаем ratingButtons
        ratingButtons.removeAll()
        
        for _ in 0..<starCount {
            // Create the button
            let button = UIButton()
            button.backgroundColor = .red
            
            // Add constraints
            
            // отключает автоматические привязки
            button.translatesAutoresizingMaskIntoConstraints = false
            // объявляем ширину и высоту привязками
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the new button on the rating button array
            ratingButtons.append(button)
        }
    }
    
}
