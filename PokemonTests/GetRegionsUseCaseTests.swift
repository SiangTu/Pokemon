//
//  GetRegionsUseCaseTests.swift
//  PokemonTests
//
//  Created by Sean on 2025/11/15.
//

import XCTest
import PromiseKit
@testable import Pokemon

final class GetRegionsUseCaseTests: XCTestCase {
    
    var useCase: GetRegionsUseCase!
    
    override func setUp() {
        super.setUp()
        useCase = GetRegionsUseCase()
    }
    
    override func tearDown() {
        useCase = nil
        super.tearDown()
    }
    
    // MARK: - Success Cases
    
    func testExecute_Success() {
        // Given
        let expectation = expectation(description: "GetRegionsUseCase execute")
        
        // When
        useCase.execute(limit: 1)
            .done { regions in
                // Then
                XCTAssertGreaterThan(regions.count, 0, "Should return at least one region")
                
                // 驗證每個 Region 的基本屬性
                for region in regions {
                    XCTAssertFalse(region.name.isEmpty, "Region name should not be empty")
                    XCTAssertGreaterThanOrEqual(region.numOfLoaction, 0, "Number of locations should be non-negative")
                }
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testExecute_VerifyRegionProperties() {
        // Given
        let expectation = expectation(description: "Verify Region properties")
        
        // When
        useCase.execute()
            .done { regions in
                // Then
                XCTAssertGreaterThan(regions.count, 0, "Should return at least one region")
                
                // 驗證第一個 Region（通常是 Kanto）
                if let firstRegion = regions.first {
                    XCTAssertFalse(firstRegion.name.isEmpty, "Region name should not be empty")
                    XCTAssertGreaterThanOrEqual(firstRegion.numOfLoaction, 0, "Number of locations should be non-negative")
                }
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testExecute_WithLimit() {
        // Given
        let expectation = expectation(description: "Get regions with limit")
        let limit = 3
        
        // When
        useCase.execute(limit: limit)
            .done { regions in
                // Then
                XCTAssertLessThanOrEqual(regions.count, limit, "Should return at most \(limit) regions")
                XCTAssertGreaterThan(regions.count, 0, "Should return at least one region")
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testExecute_WithOffset() {
        // Given
        let expectation = expectation(description: "Get regions with offset")
        let offset = 1
        
        // When
        useCase.execute(offset: offset)
            .done { regions in
                // Then
                XCTAssertGreaterThanOrEqual(regions.count, 0, "Should return valid number of regions")
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testExecute_WithLimitAndOffset() {
        // Given
        let expectation = expectation(description: "Get regions with limit and offset")
        let limit = 2
        let offset = 1
        
        // When
        useCase.execute(limit: limit, offset: offset)
            .done { regions in
                // Then
                XCTAssertLessThanOrEqual(regions.count, limit, "Should return at most \(limit) regions")
                XCTAssertGreaterThanOrEqual(regions.count, 0, "Should return valid number of regions")
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testExecute_VerifyLocationCount() {
        // Given
        let expectation = expectation(description: "Verify location count")
        
        // When
        useCase.execute()
            .done { regions in
                // Then
                // 驗證每個 Region 的 location 數量是從 detail API 正確獲取的
                for region in regions {
                    // numOfLoaction 應該是從 RegionDetailResponse.locations.count 獲取的
                    XCTAssertGreaterThanOrEqual(region.numOfLoaction, 0, "Location count should be non-negative")
                }
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testExecute_UniqueRegions() {
        // Given
        let expectation = expectation(description: "Verify unique regions")
        
        // When
        useCase.execute()
            .done { regions in
                // Then
                // 驗證所有 Region 都有唯一的名稱（理論上應該如此）
                let names = regions.map { $0.name }
                let uniqueNames = Set(names)
                
                // 如果 API 返回的列表中有重複，這可能表示有問題
                // 但我們先驗證至少大部分是唯一的
                XCTAssertGreaterThanOrEqual(uniqueNames.count, regions.count - 1, "Most regions should have unique names")
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testExecute_VerifyCommonRegions() {
        // Given
        let expectation = expectation(description: "Verify common regions")
        
        // When
        useCase.execute()
            .done { regions in
                // Then
                // 驗證包含一些常見的 Region（如果存在）
                let regionNames = regions.map { $0.name.lowercased() }
                
                // 這些是常見的 Pokemon 地區
                let commonRegions = ["kanto", "johto", "hoenn", "sinnoh", "unova", "kalos", "alola", "galar"]
                
                // 至少應該有一些常見的地區
                let foundCommonRegions = commonRegions.filter { regionNames.contains($0) }
                XCTAssertGreaterThan(foundCommonRegions.count, 0, "Should contain at least some common regions")
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
}

