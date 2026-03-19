//
//  MainViewModel.swift
//  Pokemon
//
//  Created by Sean on 2025/11/16.
//

import Foundation
import PromiseKit

struct MainViewModel {
    private let getPokemonsUseCase = GetPokemonsUseCase()
    private let getPokemonTypesUseCase = GetPokemonTypesUseCase()
    private let getRegionsUseCase = GetRegionsUseCase()
    
    func getPokemons() -> Promise<[Pokemon]> {
        // 限制9個 offset不設定
        return getPokemonsUseCase.execute(limit: 9, offset: nil)
    }
    
    func getRegions() -> Promise<[Region]> {
        // 6個 offset 不設定
        return getRegionsUseCase.execute(limit: 6, offset: nil)
    }
    
    func getTypes() -> Promise<[PokemonType]> {
        // limit跟offset都不設定
        return getPokemonTypesUseCase.execute(limit: nil, offset: nil)
    }
}
