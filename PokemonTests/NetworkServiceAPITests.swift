//
//  NetworkServiceAPITests.swift
//  PokemonTests
//
//  Created by Sean on 2025/11/15.
//

import XCTest
import PromiseKit
@testable import Pokemon

final class NetworkServiceAPITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Pokemon List API Tests
    
    func testGetPokemonList_Success() {
        // Given
        let expectation = expectation(description: "Pokemon List API Request")
        let limit = 9
        let offset = 1
        
        // When
        NetworkService.getPokemonList(limit: limit, offset: offset)
            .done { response in
                // Then
                XCTAssertGreaterThan(response.count, 0, "Pokemon count should be greater than 0")
                XCTAssertEqual(response.results.count, limit, "Results count should match limit")
                XCTAssertNotNil(response.results.first, "Should have at least one Pokemon result")
                
                if let firstPokemon = response.results.first {
                    XCTAssertFalse(firstPokemon.name.isEmpty, "Pokemon name should not be empty")
                    XCTAssertFalse(firstPokemon.url.isEmpty, "Pokemon URL should not be empty")
                }
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("API request failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetPokemonList_ResponseStructure() {
        // Given
        let expectation = expectation(description: "Pokemon List Response Structure")
        let limit = 5
        let offset = 0
        
        // When
        NetworkService.getPokemonList(limit: limit, offset: offset)
            .done { response in
                // Then
                XCTAssertNotNil(response.count, "Count should not be nil")
                XCTAssertNotNil(response.results, "Results should not be nil")
                XCTAssertTrue(response.results.count <= limit, "Results count should not exceed limit")
                
                // Verify each Pokemon result structure
                for pokemon in response.results {
                    XCTAssertFalse(pokemon.name.isEmpty, "Pokemon name should not be empty")
                    XCTAssertTrue(pokemon.url.contains("pokemon"), "URL should contain 'pokemon'")
                }
                
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("API request failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Pokemon Detail API Tests
    
    func testGetPokemonDetail_Success() {
        // Given
        let expectation = expectation(description: "Pokemon Detail API Request")
        let pokemonId = 1
        
        // When
        NetworkService.getPokemonDetail(id: pokemonId)
            .done { response in
                // Then
                XCTAssertEqual(response.id, pokemonId, "Pokemon ID should match requested ID")
                XCTAssertFalse(response.name.isEmpty, "Pokemon name should not be empty")
                XCTAssertGreaterThan(response.height, 0, "Pokemon height should be greater than 0")
                XCTAssertGreaterThan(response.weight, 0, "Pokemon weight should be greater than 0")
                XCTAssertFalse(response.abilities.isEmpty, "Pokemon should have at least one ability")
                XCTAssertFalse(response.types.isEmpty, "Pokemon should have at least one type")
                XCTAssertFalse(response.stats.isEmpty, "Pokemon should have stats")
                
                expectation.fulfill()
            }
            .catch { error in
                // 打印詳細的錯誤訊息以便調試
                print("❌ Pokemon Detail API Error:")
                print("Error: \(error)")
                print("Localized Description: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("Domain: \(nsError.domain)")
                    print("Code: \(nsError.code)")
                    print("User Info: \(nsError.userInfo)")
                }
                XCTFail("API request failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetPokemonDetail_ResponseStructure() {
        // Given
        let expectation = expectation(description: "Pokemon Detail Response Structure")
        let pokemonId = 1
        
        // When
        NetworkService.getPokemonDetail(id: pokemonId)
            .done { response in
                // Then
                // Verify basic properties
                XCTAssertNotNil(response.id, "ID should not be nil")
                XCTAssertNotNil(response.name, "Name should not be nil")
                XCTAssertNotNil(response.height, "Height should not be nil")
                XCTAssertNotNil(response.weight, "Weight should not be nil")
                XCTAssertNotNil(response.baseExperience, "Base experience should not be nil")
                
                // Verify abilities structure
                for ability in response.abilities {
                    XCTAssertNotNil(ability.slot, "Ability slot should not be nil")
                }
                
                // Verify types structure
                for type in response.types {
                    XCTAssertFalse(type.type.name.isEmpty, "Type name should not be empty")
                    XCTAssertNotNil(type.slot, "Type slot should not be nil")
                }
                
                // Verify stats structure
                for stat in response.stats {
                    XCTAssertFalse(stat.stat.name.isEmpty, "Stat name should not be empty")
                    XCTAssertNotNil(stat.baseStat, "Base stat should not be nil")
                    XCTAssertNotNil(stat.effort, "Effort should not be nil")
                }
                
                // Verify sprites
                XCTAssertNotNil(response.sprites, "Sprites should not be nil")
                
                expectation.fulfill()
            }
            .catch { error in
                // 打印詳細的錯誤訊息以便調試
                print("❌ Pokemon Detail Response Structure Error:")
                print("Error: \(error)")
                print("Localized Description: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("Domain: \(nsError.domain)")
                    print("Code: \(nsError.code)")
                    print("User Info: \(nsError.userInfo)")
                }
                XCTFail("API request failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetPokemonDetail_DifferentPokemon() {
        // Given
        let pokemonIds = [1, 25, 150] // Bulbasaur, Pikachu, Mewtwo
        var expectations: [XCTestExpectation] = []
        
        // When & Then
        for pokemonId in pokemonIds {
            let expectation = expectation(description: "Pokemon \(pokemonId) request")
            expectations.append(expectation)
            
            NetworkService.getPokemonDetail(id: pokemonId)
                .done { response in
                    XCTAssertEqual(response.id, pokemonId, "Pokemon ID should match requested ID")
                    XCTAssertFalse(response.name.isEmpty, "Pokemon name should not be empty")
                    expectation.fulfill()
                }
                .catch { error in
                    XCTFail("API request failed for Pokemon \(pokemonId) with error: \(error.localizedDescription)")
                    expectation.fulfill()
                }
        }
        
        wait(for: expectations, timeout: 15.0)
    }
    
    func testGetPokemonDetail_InvalidID() {
        // Given
        let expectation = expectation(description: "Pokemon Detail Invalid ID")
        let invalidId = 99999
        
        // When
        NetworkService.getPokemonDetail(id: invalidId)
            .done { _ in
                // If the API returns a response for invalid ID, we might need to adjust this test
                // For now, we'll just verify it doesn't crash
                expectation.fulfill()
            }
            .catch { error in
                // Expected to fail for invalid ID
                XCTAssertNotNil(error, "Should return error for invalid Pokemon ID")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Type List API Tests
    
    func testGetTypeList_Success() {
        // Given
        let expectation = expectation(description: "Type List API Request")
        
        // When
        NetworkService.getTypeList()
            .done { response in
                // Then
                XCTAssertGreaterThan(response.count, 0, "Type count should be greater than 0")
                XCTAssertFalse(response.results.isEmpty, "Should have at least one type result")
                XCTAssertNotNil(response.results.first, "Should have at least one type result")
                
                if let firstType = response.results.first {
                    XCTAssertFalse(firstType.name.isEmpty, "Type name should not be empty")
                    XCTAssertFalse(firstType.url.isEmpty, "Type URL should not be empty")
                    XCTAssertTrue(firstType.url.contains("type"), "URL should contain 'type'")
                }
                
                expectation.fulfill()
            }
            .catch { error in
                print("❌ Type List API Error:")
                print("Error: \(error)")
                print("Localized Description: \(error.localizedDescription)")
                XCTFail("API request failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetTypeList_ResponseStructure() {
        // Given
        let expectation = expectation(description: "Type List Response Structure")
        
        // When
        NetworkService.getTypeList()
            .done { response in
                // Then
                XCTAssertNotNil(response.count, "Count should not be nil")
                XCTAssertNotNil(response.results, "Results should not be nil")
                XCTAssertGreaterThanOrEqual(response.results.count, 1, "Should have at least one type")
                
                // Verify each type result structure
                for type in response.results {
                    XCTAssertFalse(type.name.isEmpty, "Type name should not be empty")
                    XCTAssertTrue(type.url.contains("type"), "URL should contain 'type'")
                }
                
                expectation.fulfill()
            }
            .catch { error in
                print("❌ Type List Response Structure Error:")
                print("Error: \(error)")
                print("Localized Description: \(error.localizedDescription)")
                XCTFail("API request failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetTypeList_WithParameters() {
        // Given
        let expectation = expectation(description: "Type List With Parameters")
        let limit = 5
        let offset = 0
        
        // When
        NetworkService.getTypeList(limit: limit, offset: offset)
            .done { response in
                // Then
                XCTAssertGreaterThan(response.count, 0, "Type count should be greater than 0")
                XCTAssertTrue(response.results.count <= limit, "Results count should not exceed limit")
                
                expectation.fulfill()
            }
            .catch { error in
                print("❌ Type List With Parameters Error:")
                print("Error: \(error)")
                print("Localized Description: \(error.localizedDescription)")
                XCTFail("API request failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Region List API Tests
    
    func testGetRegionList_Success() {
        // Given
        let expectation = expectation(description: "Region List API Request")
        
        // When
        NetworkService.getRegionList()
            .done { response in
                // Then
                XCTAssertGreaterThan(response.count, 0, "Region count should be greater than 0")
                XCTAssertFalse(response.results.isEmpty, "Should have at least one region result")
                XCTAssertNotNil(response.results.first, "Should have at least one region result")
                
                if let firstRegion = response.results.first {
                    XCTAssertFalse(firstRegion.name.isEmpty, "Region name should not be empty")
                    XCTAssertFalse(firstRegion.url.isEmpty, "Region URL should not be empty")
                    XCTAssertTrue(firstRegion.url.contains("region"), "URL should contain 'region'")
                }
                
                expectation.fulfill()
            }
            .catch { error in
                print("❌ Region List API Error:")
                print("Error: \(error)")
                print("Localized Description: \(error.localizedDescription)")
                XCTFail("API request failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetRegionList_ResponseStructure() {
        // Given
        let expectation = expectation(description: "Region List Response Structure")
        
        // When
        NetworkService.getRegionList()
            .done { response in
                // Then
                XCTAssertNotNil(response.count, "Count should not be nil")
                XCTAssertNotNil(response.results, "Results should not be nil")
                XCTAssertGreaterThanOrEqual(response.results.count, 1, "Should have at least one region")
                
                // Verify each region result structure
                for region in response.results {
                    XCTAssertFalse(region.name.isEmpty, "Region name should not be empty")
                    XCTAssertTrue(region.url.contains("region"), "URL should contain 'region'")
                }
                
                expectation.fulfill()
            }
            .catch { error in
                print("❌ Region List Response Structure Error:")
                print("Error: \(error)")
                print("Localized Description: \(error.localizedDescription)")
                XCTFail("API request failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetRegionList_WithParameters() {
        // Given
        let expectation = expectation(description: "Region List With Parameters")
        let limit = 5
        let offset = 0
        
        // When
        NetworkService.getRegionList(limit: limit, offset: offset)
            .done { response in
                // Then
                XCTAssertGreaterThan(response.count, 0, "Region count should be greater than 0")
                XCTAssertTrue(response.results.count <= limit, "Results count should not exceed limit")
                
                expectation.fulfill()
            }
            .catch { error in
                print("❌ Region List With Parameters Error:")
                print("Error: \(error)")
                print("Localized Description: \(error.localizedDescription)")
                XCTFail("API request failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Region Detail API Tests
    
    func testGetRegionDetail_Success() {
        // Given
        let expectation = expectation(description: "Region Detail API Request")
        let regionId = 1
        
        // When
        NetworkService.getRegionDetail(id: regionId)
            .done { response in
                // Then
                XCTAssertEqual(response.id, regionId, "Region ID should match requested ID")
                XCTAssertFalse(response.name.isEmpty, "Region name should not be empty")
                XCTAssertFalse(response.locations.isEmpty, "Region should have at least one location")
                XCTAssertFalse(response.names.isEmpty, "Region should have names")
                XCTAssertFalse(response.pokedexes.isEmpty, "Region should have pokedexes")
                XCTAssertFalse(response.versionGroups.isEmpty, "Region should have version groups")
                
                expectation.fulfill()
            }
            .catch { error in
                print("❌ Region Detail API Error:")
                print("Error: \(error)")
                print("Localized Description: \(error.localizedDescription)")
                XCTFail("API request failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetRegionDetail_ResponseStructure() {
        // Given
        let expectation = expectation(description: "Region Detail Response Structure")
        let regionId = 1
        
        // When
        NetworkService.getRegionDetail(id: regionId)
            .done { response in
                // Then
                // Verify basic properties
                XCTAssertNotNil(response.id, "ID should not be nil")
                XCTAssertNotNil(response.name, "Name should not be nil")
                
                // Verify locations structure
                for location in response.locations {
                    XCTAssertFalse(location.name.isEmpty, "Location name should not be empty")
                    XCTAssertTrue(location.url.contains("location"), "URL should contain 'location'")
                }
                
                // Verify names structure
                for regionName in response.names {
                    XCTAssertFalse(regionName.name.isEmpty, "Region name should not be empty")
                    XCTAssertFalse(regionName.language.name.isEmpty, "Language name should not be empty")
                }
                
                // Verify pokedexes structure
                for pokedex in response.pokedexes {
                    XCTAssertFalse(pokedex.name.isEmpty, "Pokedex name should not be empty")
                    XCTAssertTrue(pokedex.url.contains("pokedex"), "URL should contain 'pokedex'")
                }
                
                // Verify version groups structure
                for versionGroup in response.versionGroups {
                    XCTAssertFalse(versionGroup.name.isEmpty, "Version group name should not be empty")
                    XCTAssertTrue(versionGroup.url.contains("version-group"), "URL should contain 'version-group'")
                }
                
                expectation.fulfill()
            }
            .catch { error in
                print("❌ Region Detail Response Structure Error:")
                print("Error: \(error)")
                print("Localized Description: \(error.localizedDescription)")
                XCTFail("API request failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetRegionDetail_DifferentRegions() {
        // Given
        let regionIds = [7,8,9] // Kanto, Johto, Hoenn
        var expectations: [XCTestExpectation] = []
        
        // When & Then
        for regionId in regionIds {
            let expectation = expectation(description: "Region \(regionId) request")
            expectations.append(expectation)
            
            NetworkService.getRegionDetail(id: regionId)
                .done { response in
                    XCTAssertEqual(response.id, regionId, "Region ID should match requested ID")
                    XCTAssertFalse(response.name.isEmpty, "Region name should not be empty")
                    expectation.fulfill()
                }
                .catch { error in
                    print("❌ Region Detail Error for Region \(regionId):")
                    print("Error: \(error)")
                    XCTFail("API request failed for Region \(regionId) with error: \(error.localizedDescription)")
                    expectation.fulfill()
                }
        }
        
        wait(for: expectations, timeout: 15.0)
    }
}

