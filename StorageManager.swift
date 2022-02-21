//
//  StorageManager.swift
//  PetPasport
//
//  Created by Сергей on 09.07.2020.
//  Copyright © 2020 Сергей. All rights reserved.
//

import RealmSwift


let realm = try! Realm()

class StorageManager {
    
    static func saveObject (_ pet: Pet) {
        try! realm.write{
            realm.add(pet)
        }
    }
    
    static func deleteObject (_ pet: Pet) {
        try! realm.write {
            realm.delete(pet)
        }
    }
}
