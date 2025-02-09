//
//  Pokemon.swift
//  PokemonRoulette
//
//  Created by 佐久間涼 on 2025/01/16.
//

import Foundation

struct Pokemon: Hashable {
    // View上にリストとして表示させる要素は一位でなければならない。
    let uuid: UUID = UUID()
    
    let pokedexId: String
    let name: String
    var didDraw: Bool
    
    init (_ pokedexId: String,_ name: String,_ didDraw: Bool) {
        self.pokedexId = pokedexId
        self.name = name
        self.didDraw = didDraw
    }
}
