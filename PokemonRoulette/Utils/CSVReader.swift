//
//  CSVReader.swift
//  PokemonRoulette
//
//  Created by 佐久間涼 on 2025/01/20.
//

import Foundation

struct CSVReader {
    
    static func loadCsv(fileName: String) -> [[String]] {
        
        // [ "FileName", ".csv" ]に分割する。
        let fileArr: [String] = fileName.components(separatedBy: ".")
        
        guard let fileURL = Bundle.main.url(forResource: fileArr[0], withExtension: fileArr[1])  else {
            fatalError("ファイルが見つかりません。")
        }
        
        guard let contentData = try? String(contentsOf: fileURL, encoding: String.Encoding.utf8)
        else {
            fatalError("CSVファイルの読み込みに失敗しました。")
        }
        
        let rows: [[String]] = contentData.components(separatedBy: "\n")
            .filter { !$0.isEmpty }
            .map({ row in
                return row.components(separatedBy: ",")
            })
        
        return rows
    }
}
