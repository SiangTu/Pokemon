//
//  MoyaProvider+PromiseKit.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import Moya
import PromiseKit
import Foundation

extension MoyaProvider {
    func request<D: Decodable>(_ target: Target,
                               responseType: D.Type,
                      callbackQueue: DispatchQueue? = .none,
                      progress: ProgressBlock? = .none) -> Promise<D> {
        return Promise<D>.init { [weak self] resolver in
            guard let self else {
                resolver.reject(CommonError.instanceDeallocated)
                return
            }
            self.request(
                target,
                callbackQueue: callbackQueue,
                progress: progress
            ) { result in
                switch result {
                case .success(let moyaResponse):
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let response = try decoder.decode(D.self, from: moyaResponse.data)
                        resolver.fulfill(response)
                    } catch let decodingError as DecodingError {
                        // 提供更詳細的解碼錯誤訊息
                        var errorMessage = "Decoding failed: "
                        switch decodingError {
                        case .typeMismatch(let type, let context):
                            errorMessage += "Type mismatch for type \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                            if let jsonString = String(data: moyaResponse.data, encoding: .utf8) {
                                errorMessage += "\nJSON: \(jsonString.prefix(500))"
                            }
                        case .valueNotFound(let type, let context):
                            errorMessage += "Value not found for type \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                        case .keyNotFound(let key, let context):
                            errorMessage += "Key '\(key.stringValue)' not found at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                            if let jsonString = String(data: moyaResponse.data, encoding: .utf8) {
                                errorMessage += "\nJSON: \(jsonString.prefix(500))"
                            }
                        case .dataCorrupted(let context):
                            errorMessage += "Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
                        @unknown default:
                            errorMessage += "Unknown decoding error: \(decodingError.localizedDescription)"
                        }
                        let detailedError = NSError(domain: "DecodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        resolver.reject(detailedError)
                    } catch {
                        resolver.reject(error)
                    }
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
    }
}
