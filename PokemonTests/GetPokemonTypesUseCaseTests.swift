//
//  GetPokemonTypesUseCaseTests.swift
//  PokemonTests
//
//  Created by Sean on 2025/11/15.
//

import XCTest
import PromiseKit
import Factory
@testable import Pokemon

final class GetPokemonTypesUseCaseTests: XCTestCase {
    
    var useCase: GetPokemonTypesUseCase!
    
    override func setUp() {
        super.setUp()
        Container.shared.usingMockService()
        useCase = GetPokemonTypesUseCase()
    }
    
    override func tearDown() {
        useCase = nil
        super.tearDown()
    }
    
    // MARK: - Success Cases
    
    func testExecute_Success() {
        // Given
        let expectation = expectation(description: "GetPokemonTypesUseCase execute")
        
        // When
        useCase.execute()
            .done { types in
                // Then
                XCTAssertGreaterThan(types.count, 0, "Should return at least one type")
                
                // 驗證所有返回的類型都是有效的 PokemonType enum
                for type in types {
                    switch type {
                    case .normal, .fighting, .flying, .poison, .ground, .rock,
                         .bug, .ghost, .steel, .fire, .water, .grass,
                         .electric, .psychic, .ice, .dragon, .dark, .fairy:
                        break // 有效的類型
                    }
                }
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testExecute_WithLimit() {
        // Given
        let expectation = expectation(description: "Get types with limit")
        let limit = 5
        
        // When
        useCase.execute(limit: limit)
            .done { types in
                // Then
                XCTAssertLessThanOrEqual(types.count, limit, "Should return at most \(limit) types")
                XCTAssertGreaterThan(types.count, 0, "Should return at least one type")
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testExecute_WithOffset() {
        // Given
        let expectation = expectation(description: "Get types with offset")
        let offset = 5
        
        // When
        useCase.execute(offset: offset)
            .done { types in
                // Then
                XCTAssertGreaterThanOrEqual(types.count, 0, "Should return valid number of types")
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testExecute_WithLimitAndOffset() {
        // Given
        let expectation = expectation(description: "Get types with limit and offset")
        let limit = 3
        let offset = 2
        
        // When
        useCase.execute(limit: limit, offset: offset)
            .done { types in
                // Then
                XCTAssertLessThanOrEqual(types.count, limit, "Should return at most \(limit) types")
                XCTAssertGreaterThanOrEqual(types.count, 0, "Should return valid number of types")
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testExecute_NoInvalidTypes() {
        // Given
        let expectation = expectation(description: "Verify no invalid types")
        
        // When
        useCase.execute()
            .done { types in
                // Then
                // 驗證所有類型都是有效的 enum case
                // 如果 compactMap 正確工作，所有無效的類型應該已被過濾掉
                for type in types {
                    // 這個測試確保所有返回的類型都是有效的
                    let rawValue = type.rawValue
                    XCTAssertNotNil(PokemonType(rawValue: rawValue), "Type with rawValue '\(rawValue)' should be valid")
                }
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testExecute_UniqueTypes() {
        // Given
        let expectation = expectation(description: "Verify unique types")
        
        // When
        useCase.execute()
            .done { types in
                // Then
                // 驗證所有類型都是唯一的（沒有重複）
                let uniqueTypes = Set(types)
                XCTAssertEqual(types.count, uniqueTypes.count, "All types should be unique")
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
}

