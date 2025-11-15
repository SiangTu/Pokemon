//
//  PokemonCollectionService.swift
//  Pokemon
//
//  Created by Sean on 2025/11/16.
//

import Foundation

class PokemonCollectionService {
    static let shared = PokemonCollectionService()
    
    private let userDefaults = UserDefaults.standard
    private let collectedPokemonNumbersKey = "collectedPokemonNumbers"
    
    private init() {}
    
    // 檢查 Pokemon 是否已收藏
    func isCollected(pokemonNumber: Int) -> Bool {
        let collectedNumbers = getCollectedNumbers()
        return collectedNumbers.contains(pokemonNumber)
    }
    
    // 切換收藏狀態
    func toggleCollection(pokemonNumber: Int) {
        var collectedNumbers = getCollectedNumbers()
        if collectedNumbers.contains(pokemonNumber) {
            collectedNumbers.remove(pokemonNumber)
        } else {
            collectedNumbers.insert(pokemonNumber)
        }
        saveCollectedNumbers(collectedNumbers)
    }
    
    // 設置收藏狀態
    func setCollected(_ isCollected: Bool, pokemonNumber: Int) {
        var collectedNumbers = getCollectedNumbers()
        if isCollected {
            collectedNumbers.insert(pokemonNumber)
        } else {
            collectedNumbers.remove(pokemonNumber)
        }
        saveCollectedNumbers(collectedNumbers)
    }
    
    // 獲取所有已收藏的 Pokemon numbers
    func getCollectedNumbers() -> Set<Int> {
        guard let array = userDefaults.array(forKey: collectedPokemonNumbersKey) as? [Int] else {
            return Set<Int>()
        }
        return Set(array)
    }
    
    // 保存已收藏的 Pokemon numbers
    private func saveCollectedNumbers(_ numbers: Set<Int>) {
        let array = Array(numbers)
        userDefaults.set(array, forKey: collectedPokemonNumbersKey)
    }
}

