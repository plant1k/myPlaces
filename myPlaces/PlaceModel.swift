//
//  PlaceModel.swift
//  myPlaces
//
//  Created by Андрей Цурка on 11.11.2020.
//

import UIKit

struct Place {
    
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var restaurantImage: String?
    
    
    static let restaurantNames = [
            "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
            "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
            "Speak Easy", "Morris Pub", "Вкусные истории",
            "Классик", "Love&Life", "Шок", "Бочка"
        ]
   
    static func getPlases() -> [Place] {
        
        var plases: [Place] = []
        
        for place in restaurantNames {
            
            plases.append(Place(name: place, location: "Moscow", type: "Ресторан", image: nil, restaurantImage: place))
            
        }
        
        
        return plases
    }
    
}
