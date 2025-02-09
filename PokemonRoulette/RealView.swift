//
//  RealView.swift
//  PokemonRoulette
//
//  Created by 佐久間涼 on 2025/01/14.
//

import SwiftUI

struct ReelView: View {
    @StateObject var rs = realState
    @Binding var dispArr: [Pokemon]
    
    @ViewBuilder
    private func squareForEach(_ arr: [Pokemon]) -> some View {
        ForEach(arr, id: \.self) { pokemon in
            Text("\(pokemon.name)(\(pokemon.pokedexId))")
                .font(Font.system(size: 30))
                .foregroundColor(.gray)
                .frame(width: Const.width, height: Const.height)
                .background(Color.white)
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                // ルーレットのぐるぐるする部分
                VStack(spacing: 0) {
                    squareForEach(dispArr)
                }
                .offset(.init(width: 0, height: rs.offset)) // ここのheightを動的にし、スクロールさせる
            }
            .frame(width: Const.width, height: Const.scrollViewHeight)
            .background(Color.white)
            Rectangle()
                .stroke(Color.red, lineWidth: 2)
                .frame(width: Const.width, height: Const.height)
        }
    }
}
