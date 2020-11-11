//
//  PlaceModel.swift
//  myPlaces
//
//  Created by Андрей Цурка on 11.11.2020.
//

import Foundation

struct Place {
    
    let name: String
    let location: String
    let type: String
    let image: String
    
    
    static var restaurantNames = [
            "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
            "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
            "Speak Easy", "Morris Pub", "Вкусные истории",
            "Классик", "Love&Life", "Шок", "Бочка"
        ]
   
    static func getPlases() -> [Place] {
        
        var plases: [Place] = []
        
        for place in restaurantNames {
            
            plases.append(Place(name: place, location: "Moscow", type: "Ресторан", image: place))
            
        }
        
        
        return plases
    }
    
}
