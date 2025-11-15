//
//  Array+Chunked.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        print(count)
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

