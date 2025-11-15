//
//  RegionAPI.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import Foundation
import Moya

struct RegionListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [RegionResult]
    
    struct RegionResult: Codable {
        let name: String
        let url: String
    }
}

struct GetRegionList {
    let limit: Int?
    let offset: Int?
    
    init(limit: Int? = nil, offset: Int? = nil) {
        self.limit = limit
        self.offset = offset
    }
}

extension GetRegionList: TargetType {
    
    var baseURL: URL {
        ApiConstant.baseUrl
    }
    
    var path: String {
        "region"
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Moya.Task {
        var parameters: [String: Any] = [:]
        if let limit = limit {
            parameters["limit"] = limit
        }
        if let offset = offset {
            parameters["offset"] = offset
        }
        
        if parameters.isEmpty {
            return .requestPlain
        } else {
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        nil
    }
}

struct RegionDetailResponse: Codable {
    let id: Int
    let locations: [LocationResource]
    let mainGeneration: NamedAPIResource?
    let name: String
    let names: [RegionName]
    let pokedexes: [NamedAPIResource]
    let versionGroups: [NamedAPIResource]
    
    struct LocationResource: Codable {
        let name: String
        let url: String
    }
    
    struct NamedAPIResource: Codable {
        let name: String
        let url: String
    }
    
    struct RegionName: Codable {
        let language: NamedAPIResource
        let name: String
    }
}

struct GetRegionDetail {
    let id: Int
}

extension GetRegionDetail: TargetType {
    
    var baseURL: URL {
        ApiConstant.baseUrl
    }
    
    var path: String {
        "region/\(id)"
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Moya.Task {
        .requestPlain
    }
    
    var headers: [String : String]? {
        nil
    }
}

