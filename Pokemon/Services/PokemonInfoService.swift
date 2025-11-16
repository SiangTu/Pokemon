//
//  PokemonInfoService.swift
//  Pokemon
//
//  Created by Sean on 2025/11/16.
//

import PromiseKit
import Foundation

protocol PokemonInfoService {
        
        func getPokemonList(limit: Int, offset: Int?) -> Promise<PokemonListResponse>
        
        func getPokemonDetail(id: Int) -> Promise<PokemonDetailResponse>
        
        func getTypeList(limit: Int?, offset: Int?) -> Promise<TypeListResponse>
        
        func getRegionList(limit: Int?, offset: Int?) -> Promise<RegionListResponse>
        
        func getRegionDetail(id: Int) -> Promise<RegionDetailResponse>
        
        func loadImage(from url: URL) -> Promise<Data>
}
