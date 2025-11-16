//
//  MockCollectionService.swift
//  PokemonTests
//
//  Created by Sean on 2025/11/16.
//

import Foundation
@testable import Pokemon

class MockCollectionService: CollectionService {
    
    // MARK: - Properties for controlling mock behavior
    
    private var collectedPokemonNumbers: Set<Int> = []
    
    // MARK: - CollectionService Implementation
    
    func isCollected(pokemonNumber: Int) -> Bool {
        return collectedPokemonNumbers.contains(pokemonNumber)
    }
    
    func toggleCollection(pokemonNumber: Int) {
        if collectedPokemonNumbers.contains(pokemonNumber) {
            collectedPokemonNumbers.remove(pokemonNumber)
        } else {
            collectedPokemonNumbers.insert(pokemonNumber)
        }
    }
    
    // MARK: - Additional Methods (for compatibility with PokemonCollectionService)
    
    func setCollected(_ isCollected: Bool, pokemonNumber: Int) {
        if isCollected {
            collectedPokemonNumbers.insert(pokemonNumber)
        } else {
            collectedPokemonNumbers.remove(pokemonNumber)
        }
    }
    
    func getCollectedNumbers() -> Set<Int> {
        return collectedPokemonNumbers
    }
    
    // MARK: - Helper Methods for Testing
    
    func reset() {
        collectedPokemonNumbers.removeAll()
    }
    
    func setCollectedNumbers(_ numbers: Set<Int>) {
        collectedPokemonNumbers = numbers
    }
    
    func addCollectedNumber(_ number: Int) {
        collectedPokemonNumbers.insert(number)
    }
    
    func removeCollectedNumber(_ number: Int) {
        collectedPokemonNumbers.remove(number)
    }
}

