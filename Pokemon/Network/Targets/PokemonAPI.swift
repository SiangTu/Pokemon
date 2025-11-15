//
//  PokemonAPI.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import Foundation
import Moya

struct PokemonListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonResult]
    
    struct PokemonResult: Codable {
        let name: String
        let url: String
    }
}

struct GetPokemonList {
    let limit: Int
    let offset: Int?
}

extension GetPokemonList: TargetType {
    
    var baseURL: URL {
        ApiConstant.baseUrl
    }
    
    var path: String {
        "pokemon"
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Moya.Task {
        var parameters: [String: Any] = ["limit": limit]
        if let offset = offset {
            parameters["offset"] = offset
        }
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        nil
    }
}
