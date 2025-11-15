//
//  TypeAPI.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import Foundation
import Moya

struct TypeListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [TypeResult]
    
    struct TypeResult: Codable {
        let name: String
        let url: String
    }
}

struct GetTypeList {
    let limit: Int?
    let offset: Int?
    
    init(limit: Int? = nil, offset: Int? = nil) {
        self.limit = limit
        self.offset = offset
    }
}

extension GetTypeList: TargetType {
    
    var baseURL: URL {
        ApiConstant.baseUrl
    }
    
    var path: String {
        "type"
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

