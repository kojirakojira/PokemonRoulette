//
//  RouletteResult.swift
//  PokemonRoulette
//
//  Created by 佐久間涼 on 2025/01/16.
//

import SwiftUI
import CoreData

struct RouletteResultView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @Binding var openDetailView: Bool
    @Binding var willDraw: Bool
    let pokedexId: String
    let name: String
    
    var body: some View {
        VStack {
            Spacer()
            Text("図鑑ID: \(pokedexId)")
                .font(.system(size: 48))
            Text("ポケモン: \(name)")
                .font(.system(size: 48))
            Spacer()
            Text("このポケモンを描きますか？")
                .font(.system(size: 24))
            HStack {
                Button {
                    updatePokemonModel()
                    
                    willDraw = true
                    openDetailView = false
                    print("更新完了")
                } label: {
                    Text("はい")
                        .frame(width: 100, height: 100)
                        .padding()
                        .font(Font.largeTitle)
                        .background(Color(red: 240/255, green: 248/255, blue: 255/255))
                        .foregroundStyle(.blue)
                        .cornerRadius(10)
                }
                Button {
                    willDraw = false
                    openDetailView = false
                } label: {
                    Text("いいえ")
                        .frame(width: 100, height: 100)
                        .padding()
                        .font(Font.largeTitle)
                        .background(Color(red: 240/255, green: 248/255, blue: 255/255))
                        .foregroundStyle(.red)
                        .cornerRadius(10)
                }
            }
            Spacer()
        }
    }
    
    private func updatePokemonModel() -> Void {
        
        let workersFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PokemonModel")
        let predicate = NSPredicate(format: "pokedexId = %@", pokedexId)
        workersFetch.predicate = predicate
            
        do {
            let pokemonModel = try self.viewContext.fetch(workersFetch) as! [PokemonModel]
            for p in pokemonModel {
                p.didDraw = true
                print("更新したpokedexId: \(p.pokedexId!)")
            }
        } catch let error as NSError {
            print(error)
        }
        try! self.viewContext.save()
    }
}

#Preview {
    let persistenceController = PersistenceController()
    
    RouletteResultView(
        openDetailView: Binding.constant(true),
        willDraw: Binding.constant(false),
        pokedexId: "0001N01",
        name: "フシギダネ")
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
}
