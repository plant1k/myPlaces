//
//  StorageManager.swift
//  myPlaces
//
//  Created by Андрей Цурка on 17.11.2020.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write{
            realm.add(place)
        }
    }
    
}


