//
//  NetworkService.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import Moya
import PromiseKit

class NetworkService {
    
    static func getPokemonList(limit: Int, offset: Int) -> Promise<PokemonListResponse> {
        let getPokemonList = GetPokemonList.init(limit: limit, offset: offset)
        let provider = MoyaProvider<GetPokemonList>()
        return provider.request(getPokemonList, responseType: PokemonListResponse.self)
    }
    
    static func getPokemonDetail(id: Int) -> Promise<PokemonDetailResponse> {
        let getPokemonDetail = GetPokemonDetail.init(id: id)
        let provider = MoyaProvider<GetPokemonDetail>()
        return provider.request(getPokemonDetail, responseType: PokemonDetailResponse.self)
    }
    
    static func getTypeList(limit: Int? = nil, offset: Int? = nil) -> Promise<TypeListResponse> {
        let getTypeList = GetTypeList.init(limit: limit, offset: offset)
        let provider = MoyaProvider<GetTypeList>()
        return provider.request(getTypeList, responseType: TypeListResponse.self)
    }
    
    static func getRegionList(limit: Int? = nil, offset: Int? = nil) -> Promise<RegionListResponse> {
        let getRegionList = GetRegionList.init(limit: limit, offset: offset)
        let provider = MoyaProvider<GetRegionList>()
        return provider.request(getRegionList, responseType: RegionListResponse.self)
    }
    
    static func getRegionDetail(id: Int) -> Promise<RegionDetailResponse> {
        let getRegionDetail = GetRegionDetail.init(id: id)
        let provider = MoyaProvider<GetRegionDetail>()
        return provider.request(getRegionDetail, responseType: RegionDetailResponse.self)
    }
}
