//
//  GetPokemonsUseCase.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import PromiseKit
import Factory
import UIKit

struct GetPokemonsUseCase {
    
    @Injected(\.pokemonInfoService) private var pokemonInfoService: PokemonInfoService
    
    func execute(limit: Int, offset: Int? = nil) -> Promise<[Pokemon]> {
        // 1. 先取得 Pokemon 列表
        return pokemonInfoService.getPokemonList(limit: limit, offset: offset)
            .then { listResponse -> Promise<[Pokemon]> in
                // 2. 從列表中提取每個 Pokemon 的 ID
                let pokemonPromises = listResponse.results.compactMap { pokemonResult -> Promise<Pokemon>? in
                    guard let id = self.extractID(from: pokemonResult.url) else {
                        return nil
                    }
                    
                    // 3. 對每個 ID 調用 detail API，然後轉換成 Pokemon 物件
                    return pokemonInfoService.getPokemonDetail(id: id)
                        .map { detailResponse in
                            // 4. 轉換成 Pokemon 物件（不需要等待圖片載入）
                            return self.convertToPokemon(detailResponse: detailResponse)
                        }
                }
                
                // 5. 等待所有 Promise 完成
                return when(fulfilled: pokemonPromises)
            }
    }
    
    // 從 URL 中提取 ID（最後一個 path）
    private func extractID(from url: String) -> Int? {
        let components = url.components(separatedBy: "/")
        return components.dropLast().last.flatMap { Int($0) }
    }
    
    // 將 PokemonDetailResponse 轉換成 Pokemon 物件
    private func convertToPokemon(detailResponse: PokemonDetailResponse) -> Pokemon {
        // 轉換 types（使用 PokemonType 的 init(string:)）
        let pokemonTypes = detailResponse.types.map { type -> PokemonType in
            PokemonType(rawValue: type.type.name) ?? .normal
        }
        
        // 取得 stats
        let hp = getStatValue(from: detailResponse.stats, statName: "hp") ?? 0
        let attack = getStatValue(from: detailResponse.stats, statName: "attack") ?? 0
        let defense = getStatValue(from: detailResponse.stats, statName: "defense") ?? 0
        let speed = getStatValue(from: detailResponse.stats, statName: "speed") ?? 0
        
        // 取得圖片 URL 並創建 Promise
        let imageURL = detailResponse.sprites.frontDefault
        
        let imagePromise: Promise<Data>
        if let urlString = imageURL, let url = URL(string: urlString) {
            // 使用 URLSession 載入圖片
            imagePromise = pokemonInfoService.loadImage(from: url)
        } else {
            imagePromise = .init(error: CommonError.missingRequiredValue)
        }
        
        return Pokemon(
            number: detailResponse.id,
            name: detailResponse.name,
            types: pokemonTypes,
            image: imagePromise,
            weight: detailResponse.weight,
            height: detailResponse.height,
            hp: hp,
            defense: defense,
            attack: attack,
            speed: speed,
            hdImageUrl: try? detailResponse.sprites.other?.officialArtwork?.frontDefault?.asURL()
        )
    }
    
    // 從 stats 陣列中取得指定 stat 的值
    private func getStatValue(from stats: [PokemonDetailResponse.PokemonStat], statName: String) -> Int? {
        return stats.first(where: { $0.stat.name == statName })?.baseStat
    }
}
