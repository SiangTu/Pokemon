//
//  Container+MockService.swift
//  Pokemon
//
//  Created by Sean on 2025/11/16.
//

import Factory
@testable import Pokemon

extension Container {
    func usingMockService() {
        Container.shared.collectionService.register {
            MockCollectionService()
        }
        Container.shared.pokemonInfoService.register {
            MockPokemonInfoService()
        }
    }
}
