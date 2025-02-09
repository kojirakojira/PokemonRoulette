//
//  PersistenceController.swift
//  PokemonRoulette
//
//  Created by 佐久間涼 on 2025/01/20.
//

import Foundation
import CoreData

struct PersistenceController {
    let container: NSPersistentContainer
    
    init () {
        container = NSPersistentContainer(name: "PokemonModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error: \(error)")
            }
        }
    }
}
