//
//  SecondView.swift
//  PokemonRoulette
//
//  Created by 佐久間涼 on 2025/01/13.
//

import SwiftUI
import CoreData

struct EditListView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @State private var arr: [PokemonModel] = []
//    @State private var isShowToast: Bool = false
//    @State private var changedName: String = ""
    @State var toastQueue = ToastQueue()
    @State private var disabled: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    ForEach($arr, id: \.self) { pokemonModel in
                        let pokedexId = pokemonModel.pokedexId.wrappedValue!
                        let name = pokemonModel.name.wrappedValue!
                        var didDraw = pokemonModel.didDraw.wrappedValue
                        HStack {
                            Text("\(pokedexId): \(name)")
                                .font(Font.system(size: 30))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button {
                                disabled = true
                                let success = updatePokemonModel(pokemonModel: pokemonModel.wrappedValue)
                                if (success) {
                                    didDraw = !didDraw
                                }
                                
                                toastQueue.append(.elem("\(name)が更新されました。", ""))
                                disabled = false
                            } label: {
                                Text(didDraw ? "済" : "未")
                                    .padding()
                                    .background(disabled ? Color.gray : (didDraw ? Color.red : Color.blue))
                                    .foregroundStyle(.black)
                                    .cornerRadius(10)
                                    .disabled(disabled)
                            }
                        }
                    }
                }
            }
            Toast(toastQueue: toastQueue)
        }
        .onAppear {
            let req: NSFetchRequest<PokemonModel> = PokemonModel.fetchRequest()
            var result = try! self.viewContext.fetch(req)
            result.sort { o1, o2 in
                return Int(o1.pokedexId!.prefix(4))! < Int(o2.pokedexId!.prefix(4))!
            }
            
            self.arr.removeAll()
            result.forEach { pokemonModel in
                arr.append(pokemonModel)
            }
        }
    }
    
    private func updatePokemonModel(pokemonModel: PokemonModel) -> Bool {
        
        let workersFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PokemonModel")
        let predicate = NSPredicate(format: "pokedexId = %@", pokemonModel.pokedexId!)
        workersFetch.predicate = predicate
        
        do {
            let pmArr = try self.viewContext.fetch(workersFetch) as! [PokemonModel]
            for p in pmArr {
                p.didDraw = !pokemonModel.didDraw
                print("更新したpokedexId: \(p.pokedexId!)")
            }
        } catch let error as NSError {
            print(error)
            
            return false
        }
        try! self.viewContext.save()
        
        return true
    }
}

#Preview {
    let persistenceController = PersistenceController()
    
    EditListView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)

    
}
