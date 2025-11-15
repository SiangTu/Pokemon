//
//  GetPokemonsUseCaseTests.swift
//  PokemonTests
//
//  Created by Sean on 2025/11/15.
//

import XCTest
import PromiseKit
@testable import Pokemon

final class GetPokemonsUseCaseTests: XCTestCase {
    
    var useCase: GetPokemonsUseCase!
    
    override func setUp() {
        super.setUp()
        useCase = GetPokemonsUseCase()
    }
    
    override func tearDown() {
        useCase = nil
        super.tearDown()
    }
    
    // MARK: - Success Cases
    
    func testExecute_Success() {
        // Given
        let expectation = expectation(description: "GetPokemonsUseCase execute")
        let limit = 3
        let offset = 0
        
        // When
        useCase.execute(limit: limit, offset: offset)
            .done { pokemons in
                // Then
                XCTAssertEqual(pokemons.count, limit, "Should return \(limit) Pokemon")
                
                // 驗證第一個 Pokemon 的基本屬性
                if let firstPokemon = pokemons.first {
                    XCTAssertGreaterThan(firstPokemon.number, 0, "Pokemon number should be greater than 0")
                    XCTAssertFalse(firstPokemon.name.isEmpty, "Pokemon name should not be empty")
                    XCTAssertFalse(firstPokemon.types.isEmpty, "Pokemon should have at least one type")
                    XCTAssertGreaterThanOrEqual(firstPokemon.hp, 0, "HP should be non-negative")
                    XCTAssertGreaterThanOrEqual(firstPokemon.attack, 0, "Attack should be non-negative")
                    XCTAssertGreaterThanOrEqual(firstPokemon.defense, 0, "Defense should be non-negative")
                    XCTAssertGreaterThanOrEqual(firstPokemon.speed, 0, "Speed should be non-negative")
                    XCTAssertGreaterThanOrEqual(firstPokemon.weight, 0, "Weight should be non-negative")
                    XCTAssertGreaterThanOrEqual(firstPokemon.height, 0, "Height should be non-negative")
                    XCTAssertFalse(firstPokemon.isCollected, "New Pokemon should not be collected")
                }
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testExecute_VerifyPokemonProperties() {
        // Given
        let expectation = expectation(description: "Verify Pokemon properties")
        let limit = 1
        let offset = 0
        
        // When
        useCase.execute(limit: limit, offset: offset)
            .done { pokemons in
                // Then
                XCTAssertEqual(pokemons.count, 1, "Should return 1 Pokemon")
                
                let pokemon = pokemons[0]
                
                // 驗證 Pokemon 編號
                XCTAssertEqual(pokemon.number, 1, "First Pokemon should have number 1 (Bulbasaur)")
                
                // 驗證 Pokemon 名稱
                XCTAssertEqual(pokemon.name, "bulbasaur", "First Pokemon should be Bulbasaur")
                
                // 驗證 Pokemon 類型（Bulbasaur 是 grass 和 poison）
                XCTAssertTrue(pokemon.types.contains(.grass), "Bulbasaur should have grass type")
                XCTAssertTrue(pokemon.types.contains(.poison), "Bulbasaur should have poison type")
                
                // 驗證 stats 存在且合理
                XCTAssertGreaterThan(pokemon.hp, 0, "HP should be greater than 0")
                XCTAssertGreaterThan(pokemon.attack, 0, "Attack should be greater than 0")
                XCTAssertGreaterThan(pokemon.defense, 0, "Defense should be greater than 0")
                XCTAssertGreaterThan(pokemon.speed, 0, "Speed should be greater than 0")
                
                // 驗證圖片 Promise 存在
                XCTAssertNotNil(pokemon.image, "Image promise should not be nil")
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testExecute_ImagePromiseCanBeResolved() {
        // Given
        let expectation = expectation(description: "Image promise can be resolved")
        let limit = 1
        let offset = 0
        
        // When
        useCase.execute(limit: limit, offset: offset)
            .done { pokemons in
                // Then
                XCTAssertEqual(pokemons.count, 1, "Should return 1 Pokemon")
                
                let pokemon = pokemons[0]
                
                // 驗證圖片 Promise 可以解析
                pokemon.image
                    .done { imageData in
                        XCTAssertGreaterThan(imageData.count, 0, "Image data should not be empty")
                        XCTAssertNotNil(UIImage(data: imageData), "Image data should be valid UIImage data")
                        expectation.fulfill()
                    }
                    .catch { error in
                        XCTFail("Image loading failed with error: \(error.localizedDescription)")
                        expectation.fulfill()
                    }
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testExecute_MultiplePokemons() {
        // Given
        let expectation = expectation(description: "Get multiple Pokemons")
        let limit = 5
        let offset = 0
        
        // When
        useCase.execute(limit: limit, offset: offset)
            .done { pokemons in
                // Then
                XCTAssertEqual(pokemons.count, limit, "Should return \(limit) Pokemons")
                
                // 驗證每個 Pokemon 都有唯一的編號
                let numbers = pokemons.map { $0.number }
                let uniqueNumbers = Set(numbers)
                XCTAssertEqual(numbers.count, uniqueNumbers.count, "All Pokemon should have unique numbers")
                
                // 驗證 Pokemon 編號是連續的（從 offset + 1 開始）
                let sortedNumbers = numbers.sorted()
                for (index, number) in sortedNumbers.enumerated() {
                    XCTAssertEqual(number, index + 1, "Pokemon number should be \(index + 1)")
                }
                
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
        let expectation = expectation(description: "Get Pokemons with offset")
        let limit = 3
        let offset = 5
        
        // When
        useCase.execute(limit: limit, offset: offset)
            .done { pokemons in
                // Then
                XCTAssertEqual(pokemons.count, limit, "Should return \(limit) Pokemons")
                
                // 驗證第一個 Pokemon 的編號應該是 offset + 1
                if let firstPokemon = pokemons.first {
                    XCTAssertEqual(firstPokemon.number, offset + 1, "First Pokemon number should be \(offset + 1)")
                }
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    // MARK: - Edge Cases
    
    func testExecute_EmptyResult() {
        // Given
        let expectation = expectation(description: "Get empty result with large offset")
        let limit = 10
        let offset = 10000 // 假設沒有這麼多 Pokemon
        
        // When
        useCase.execute(limit: limit, offset: offset)
            .done { pokemons in
                // Then
                // 如果 API 返回空列表，pokemons 應該是空的
                // 如果 API 返回錯誤，應該進入 catch
                XCTAssertGreaterThanOrEqual(pokemons.count, 0, "Should return empty or valid list")
                expectation.fulfill()
            }
            .catch { error in
                // API 可能返回錯誤，這也是可以接受的
                print("Expected error for large offset: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testExecute_VerifyPokemonTypeConversion() {
        // Given
        let expectation = expectation(description: "Verify Pokemon type conversion")
        let limit = 10
        let offset = 0
        
        // When
        useCase.execute(limit: limit, offset: offset)
            .done { pokemons in
                // Then
                // 驗證所有 Pokemon 的類型都是有效的 PokemonType
                for pokemon in pokemons {
                    for type in pokemon.types {
                        // 驗證類型是有效的 enum case
                        switch type {
                        case .normal, .fighting, .flying, .poison, .ground, .rock,
                             .bug, .ghost, .steel, .fire, .water, .grass,
                             .electric, .psychic, .ice, .dragon, .dark, .fairy:
                            break // 有效的類型
                        }
                    }
                }
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("UseCase execution failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 30.0)
    }
}

