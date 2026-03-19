//
//  ContainerExtension.swift
//  Pokemon
//
//  Created by Sean on 2025/11/16.
//

import Factory

extension Container {
    var pokemonInfoService: Factory<PokemonInfoService> {
        Factory(self) { NetworkService() }
    }
    
    var collectionService: Factory<CollectionService> {
        Factory(self) { PokemonCollectionService() }
    }
}
