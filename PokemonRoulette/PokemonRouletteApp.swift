//
//  PokemonRouletteApp.swift
//  PokemonRoulette
//
//  Created by 佐久間涼 on 2025/01/04.
//

import SwiftUI

@main
struct PokemonRouletteApp: App {
    let persistenceController = PersistenceController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
