//
//  CollectionService.swift
//  Pokemon
//
//  Created by Sean on 2025/11/16.
//

protocol CollectionService {
    func toggleCollection(pokemonNumber: Int)
    func isCollected(pokemonNumber: Int) -> Bool
}
