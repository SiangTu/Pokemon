//
//  MockPokemonInfoService.swift
//  PokemonTests
//
//  Created by Sean on 2025/11/16.
//

import Foundation
import PromiseKit
@testable import Pokemon

class MockPokemonInfoService: PokemonInfoService {
    
    // MARK: - Properties for controlling mock behavior
    
    var mockPokemonListResponse: PokemonListResponse?
    var mockPokemonListError: Error?
    
    var mockPokemonDetailResponses: [Int: PokemonDetailResponse] = [:]
    var mockPokemonDetailError: Error?
    
    var mockTypeListResponse: TypeListResponse?
    var mockTypeListError: Error?
    
    var mockRegionListResponse: RegionListResponse?
    var mockRegionListError: Error?
    
    var mockRegionDetailResponses: [Int: RegionDetailResponse] = [:]
    var mockRegionDetailError: Error?
    
    var mockImageData: [URL: Data] = [:]
    var mockImageError: Error?
    
    // MARK: - PokemonInfoService Implementation
    
    func getPokemonList(limit: Int, offset: Int?) -> Promise<PokemonListResponse> {
        return Promise<PokemonListResponse> { seal in
            if let error = mockPokemonListError {
                seal.reject(error)
            } else if let response = mockPokemonListResponse {
                seal.fulfill(response)
            } else {
                // Default mock response - 根據 limit 生成相應數量的資料
                let startIndex = offset ?? 0
                let results = (0..<limit).map { index in
                    let pokemonId = startIndex + index + 1
                    return PokemonListResponse.PokemonResult(
                        name: "pokemon-\(pokemonId)",
                        url: "https://pokeapi.co/api/v2/pokemon/\(pokemonId)/"
                    )
                }
                
                let defaultResponse = PokemonListResponse(
                    count: limit,
                    next: nil,
                    previous: nil,
                    results: results
                )
                seal.fulfill(defaultResponse)
            }
        }
    }
    
    func getPokemonDetail(id: Int) -> Promise<PokemonDetailResponse> {
        return Promise<PokemonDetailResponse> { seal in
            if let response = mockPokemonDetailResponses[id] {
                seal.fulfill(response)
            } else if let error = mockPokemonDetailError {
                seal.reject(error)
            } else {
                // Default mock response with valid data
                let defaultResponse = PokemonDetailResponse(
                    abilities: [],
                    baseExperience: 100,
                    cries: nil,
                    forms: [],
                    gameIndices: [],
                    height: 10,
                    heldItems: [],
                    id: id,
                    isDefault: true,
                    locationAreaEncounters: "",
                    moves: [],
                    name: "mock-pokemon-\(id)",
                    order: id,
                    pastAbilities: nil,
                    pastTypes: nil,
                    species: PokemonDetailResponse.NamedAPIResource(name: "mock-species", url: ""),
                    sprites: PokemonDetailResponse.PokemonSprites(
                        backDefault: nil,
                        backFemale: nil,
                        backShiny: nil,
                        backShinyFemale: nil,
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png",
                        frontFemale: nil,
                        frontShiny: nil,
                        frontShinyFemale: nil,
                        other: nil,
                        versions: nil
                    ),
                    stats: [
                        PokemonDetailResponse.PokemonStat(
                            baseStat: 80,
                            effort: 0,
                            stat: PokemonDetailResponse.NamedAPIResource(name: "hp", url: "")
                        ),
                        PokemonDetailResponse.PokemonStat(
                            baseStat: 82,
                            effort: 0,
                            stat: PokemonDetailResponse.NamedAPIResource(name: "attack", url: "")
                        ),
                        PokemonDetailResponse.PokemonStat(
                            baseStat: 83,
                            effort: 0,
                            stat: PokemonDetailResponse.NamedAPIResource(name: "defense", url: "")
                        ),
                        PokemonDetailResponse.PokemonStat(
                            baseStat: 80,
                            effort: 0,
                            stat: PokemonDetailResponse.NamedAPIResource(name: "speed", url: "")
                        )
                    ],
                    types: [
                        PokemonDetailResponse.PokemonType(
                            slot: 1,
                            type: PokemonDetailResponse.NamedAPIResource(name: "normal", url: "")
                        )
                    ],
                    weight: 100
                )
                seal.fulfill(defaultResponse)
            }
        }
    }
    
    func getTypeList(limit: Int?, offset: Int?) -> Promise<TypeListResponse> {
        return Promise<TypeListResponse> { seal in
            if let error = mockTypeListError {
                seal.reject(error)
            } else if let response = mockTypeListResponse {
                seal.fulfill(response)
            } else {
                // Default mock response - 根據 limit 生成相應數量的 type
                let allTypes = ["normal", "fighting", "flying", "poison", "ground", "rock",
                               "bug", "ghost", "steel", "fire", "water", "grass",
                               "electric", "psychic", "ice", "dragon", "dark", "fairy"]
                
                let startIndex = offset ?? 0
                let maxLimit = limit ?? allTypes.count
                let endIndex = min(startIndex + maxLimit, allTypes.count)
                let selectedTypes = Array(allTypes[startIndex..<endIndex])
                
                let results = selectedTypes.map { typeName in
                    TypeListResponse.TypeResult(
                        name: typeName,
                        url: "https://pokeapi.co/api/v2/type/\(typeName)/"
                    )
                }
                
                let defaultResponse = TypeListResponse(
                    count: allTypes.count,
                    next: nil,
                    previous: nil,
                    results: results
                )
                seal.fulfill(defaultResponse)
            }
        }
    }
    
    func getRegionList(limit: Int?, offset: Int?) -> Promise<RegionListResponse> {
        return Promise<RegionListResponse> { seal in
            if let error = mockRegionListError {
                seal.reject(error)
            } else if let response = mockRegionListResponse {
                seal.fulfill(response)
            } else {
                // Default mock response - 根據 limit 生成相應數量的 region
                let allRegions = ["kanto", "johto", "hoenn", "sinnoh", "unova", "kalos", "alola", "galar"]
                
                let startIndex = offset ?? 0
                let maxLimit = limit ?? allRegions.count
                let endIndex = min(startIndex + maxLimit, allRegions.count)
                let selectedRegions = Array(allRegions[startIndex..<endIndex])
                
                let results = selectedRegions.enumerated().map { index, regionName in
                    let regionId = startIndex + index + 1
                    return RegionListResponse.RegionResult(
                        name: regionName,
                        url: "https://pokeapi.co/api/v2/region/\(regionId)/"
                    )
                }
                
                let defaultResponse = RegionListResponse(
                    count: allRegions.count,
                    next: nil,
                    previous: nil,
                    results: results
                )
                seal.fulfill(defaultResponse)
            }
        }
    }
    
    func getRegionDetail(id: Int) -> Promise<RegionDetailResponse> {
        return Promise<RegionDetailResponse> { seal in
            if let response = mockRegionDetailResponses[id] {
                seal.fulfill(response)
            } else if let error = mockRegionDetailError {
                seal.reject(error)
            } else {
                // Default mock response - 提供至少一個 location
                let defaultResponse = RegionDetailResponse(
                    id: id,
                    locations: [
                        RegionDetailResponse.LocationResource(
                            name: "location-\(id)-1",
                            url: "https://pokeapi.co/api/v2/location/\(id)/"
                        )
                    ],
                    mainGeneration: nil,
                    name: "mock-region-\(id)",
                    names: [],
                    pokedexes: [],
                    versionGroups: []
                )
                seal.fulfill(defaultResponse)
            }
        }
    }
    
    func loadImage(from url: URL) -> Promise<Data> {
        return Promise<Data> { seal in
            if let error = mockImageError {
                seal.reject(error)
            } else if let data = mockImageData[url] {
                seal.fulfill(data)
            } else {
                // Default mock image data - 創建一個簡單的 1x1 PNG 圖片數據
                // 這是一個最小的有效 PNG 圖片（1x1 透明像素）
                let pngData = Data([
                    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
                    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
                    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 dimensions
                    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
                    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
                    0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
                    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
                    0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
                    0x42, 0x60, 0x82
                ])
                seal.fulfill(pngData)
            }
        }
    }
    
    // MARK: - Helper Methods for Testing
    
    func reset() {
        mockPokemonListResponse = nil
        mockPokemonListError = nil
        mockPokemonDetailResponses.removeAll()
        mockPokemonDetailError = nil
        mockTypeListResponse = nil
        mockTypeListError = nil
        mockRegionListResponse = nil
        mockRegionListError = nil
        mockRegionDetailResponses.removeAll()
        mockRegionDetailError = nil
        mockImageData.removeAll()
        mockImageError = nil
    }
}

