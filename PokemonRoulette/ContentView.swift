//
//  ContentView.swift
//  PokemonRoulette
//
//  Created by 佐久間涼 on 2025/01/16.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var viewContext
//    @FetchRequest(entity: PokemonModel.entity(), sortDescriptors: []) var fetchPokemonList: FetchedResults<PokemonModel>
    
    @State var pokemonArr: [Pokemon] = []
//    @State var isShow = false
    @State var toastQueue = ToastQueue()
    @State private var success = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 10) {
                    Spacer()
                    Text("Pokémon Roulette")
                        .bold()
                        .padding()
                        .font(.system(size: 48, design: .monospaced))
                    ZStack {
                        Circle()
                            .trim(from: 0.5, to: 1)
                            .frame(width: 400)
                            .foregroundColor(.red)
                        Circle()
                            .trim(from: 0, to: 0.5)
                            .frame(width: 400)
                            .foregroundColor(.white)
                        Circle()
                            .stroke(Color.black, style: StrokeStyle(lineWidth: 5))
                            .frame(width: 400)
                        VStack {
                            HStack {
                                Rectangle()
                                    .frame(width: 140, height: 10)
                                    .foregroundStyle(.black)
                                ZStack {
                                    Circle()
                                        .stroke(Color.black, style: StrokeStyle(lineWidth: 20))
                                        .fill(Color.white)
                                        .frame(width: 100)
                                }
                                Rectangle()
                                    .frame(width: 140, height: 10)
                                    .foregroundStyle(.black)
                                
                            }
                            
                        }
                    }
                    Spacer()
                    NavigationLink() {
                        RouletteView(pokemonArr: $pokemonArr)
                    } label: {
                        Text("ルーレット")
                            .padding()
                            .font(Font.title)
                            .foregroundStyle(.black)                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(width: UIScreen.main.bounds.width * 1 / 3)
                            .background(Color.orange)
                            .cornerRadius(10)

                    }
                    NavigationLink {
                        EditListView()
                    } label: {
                        Text("ポケモン情報を修正")
                            .padding()
                            .font(Font.title)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(width: UIScreen.main.bounds.width * 1 / 3)
                            .background(Color.cloudySkyBlue)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                Toast(toastQueue: toastQueue)
            }
        }
        .onAppear {
            
            // CoreDataから全件取得する。
            let req: NSFetchRequest<PokemonModel> = PokemonModel.fetchRequest()
            var result = try! self.viewContext.fetch(req)
            print("count: \(result.count)")
            
            if (result.count == 0) {
                // CoreDataにポケモンの情報が追加されていない場合は、初期化する。
                let rows = CSVReader.loadCsv(fileName: "pokemon.csv")
                rows.forEach { row in
                    let model: PokemonModel = PokemonModel(entity: PokemonModel.entity(), insertInto: self.viewContext)
                    model.pokedexId = row[0]
                    model.name = row[1] + (row[2].isEmpty ? "" : "(\(row[2]))")
                    model.didDraw = false
                    self.viewContext.insert(model)
                    
                    print(row)
                }
                try! self.viewContext.save()
                
                toastQueue.append(.elem("初期化成功", "初回起動のため、データを初期化しました。"))
                
            } else {
                print("初期化されませんでした。")
            }
            
            // CoreDataから再取得
            result = try! self.viewContext.fetch(req)
            // pokemonArrに反映
            pokemonArr.removeAll()
            
            result.forEach { record in
                pokemonArr.append(Pokemon(
                    record.pokedexId!,
                    record.name!,
                    record.didDraw))
                
            }
        }
    }
}

#Preview {
    let persistenceController = PersistenceController()
    
    ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
}
