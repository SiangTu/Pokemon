//
//  MainViewModel.swift
//  Pokemon
//
//  Created by Sean on 2025/11/16.
//

import Foundation
import PromiseKit

struct MainViewModel {
    func getPokemons() -> Promise<[Pokemon]> {
        // 限制9個 offset不設定
    }
    func getRegions() -> Promise<[Region]> {
        // 6個 offset 不設定
    }
    func getTypes() -> Promise<[PokemonType]> {
        // limit跟offset都不設定
    }
}
