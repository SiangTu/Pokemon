//
//  NetworkService.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import Moya
import UIKit
import PromiseKit

struct NetworkService: PokemonInfoService {
    
    func getPokemonList(limit: Int, offset: Int?) -> Promise<PokemonListResponse> {
        let getPokemonList = GetPokemonList.init(limit: limit, offset: offset)
        let provider = MoyaProvider<GetPokemonList>()
        return provider.request(getPokemonList, responseType: PokemonListResponse.self)
    }
    
    func getPokemonDetail(id: Int) -> Promise<PokemonDetailResponse> {
        let getPokemonDetail = GetPokemonDetail.init(id: id)
        let provider = MoyaProvider<GetPokemonDetail>()
        return provider.request(getPokemonDetail, responseType: PokemonDetailResponse.self)
    }
    
    func getTypeList(limit: Int? = nil, offset: Int? = nil) -> Promise<TypeListResponse> {
        let getTypeList = GetTypeList.init(limit: limit, offset: offset)
        let provider = MoyaProvider<GetTypeList>()
        return provider.request(getTypeList, responseType: TypeListResponse.self)
    }
    
    func getRegionList(limit: Int? = nil, offset: Int? = nil) -> Promise<RegionListResponse> {
        let getRegionList = GetRegionList.init(limit: limit, offset: offset)
        let provider = MoyaProvider<GetRegionList>()
        return provider.request(getRegionList, responseType: RegionListResponse.self)
    }
    
    func getRegionDetail(id: Int) -> Promise<RegionDetailResponse> {
        let getRegionDetail = GetRegionDetail.init(id: id)
        let provider = MoyaProvider<GetRegionDetail>()
        return provider.request(getRegionDetail, responseType: RegionDetailResponse.self)
    }
    
    // 從 URL 加載圖片（使用 URLSession）
    func loadImage(from url: URL) -> Promise<Data> {
        return Promise { seal in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    seal.reject(error)
                    return
                }
                
                guard let data = data else {
                    seal.reject(NSError(domain: "ImageLoadingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"]))
                    return
                }
                
                seal.fulfill(data)
            }.resume()
        }
    }
}
