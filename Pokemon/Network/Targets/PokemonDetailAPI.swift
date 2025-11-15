//
//  PokemonDetailAPI.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import Foundation
import Moya

struct PokemonDetailResponse: Codable {
    let abilities: [PokemonAbility]
    let baseExperience: Int
    let cries: PokemonCries?
    let forms: [PokemonForm]
    let gameIndices: [GameIndex]
    let height: Int
    let heldItems: [HeldItem]
    let id: Int
    let isDefault: Bool
    let locationAreaEncounters: String
    let moves: [PokemonMove]
    let name: String
    let order: Int
    let pastAbilities: [PastAbility]?
    let pastTypes: [PastType]?
    let species: NamedAPIResource
    let sprites: PokemonSprites
    let stats: [PokemonStat]
    let types: [PokemonType]
    let weight: Int
    
    struct PokemonAbility: Codable {
        let ability: NamedAPIResource?
        let isHidden: Bool
        let slot: Int
    }
    
    struct PokemonCries: Codable {
        let latest: String
        let legacy: String
    }
    
    struct PokemonForm: Codable {
        let name: String
        let url: String
    }
    
    struct GameIndex: Codable {
        let gameIndex: Int
        let version: NamedAPIResource
    }
    
    struct HeldItem: Codable {
        let item: NamedAPIResource
        let versionDetails: [VersionDetail]
        
        struct VersionDetail: Codable {
            let rarity: Int
            let version: NamedAPIResource
        }
    }
    
    struct PokemonMove: Codable {
        let move: NamedAPIResource
        let versionGroupDetails: [VersionGroupDetail]
        
        struct VersionGroupDetail: Codable {
            let levelLearnedAt: Int
            let moveLearnMethod: NamedAPIResource
            let order: Int?
            let versionGroup: NamedAPIResource
        }
    }
    
    struct PastAbility: Codable {
        let abilities: [PokemonAbility]
        let generation: NamedAPIResource
    }
    
    struct PastType: Codable {
        let generation: NamedAPIResource
        let types: [PokemonType]
    }
    
    struct PokemonSprites: Codable {
        let backDefault: String?
        let backFemale: String?
        let backShiny: String?
        let backShinyFemale: String?
        let frontDefault: String?
        let frontFemale: String?
        let frontShiny: String?
        let frontShinyFemale: String?
        let other: OtherSprites?
        let versions: VersionSprites?
        
        struct OtherSprites: Codable {
            let dreamWorld: DreamWorldSprites?
            let home: HomeSprites?
            let officialArtwork: OfficialArtworkSprites?
            let showdown: ShowdownSprites?
            
            enum CodingKeys: String, CodingKey {
                case dreamWorld
                case home
                case officialArtwork  = "official-artwork"
                case showdown
            }
            
            struct DreamWorldSprites: Codable {
                let frontDefault: String?
                let frontFemale: String?
            }
            
            struct HomeSprites: Codable {
                let frontDefault: String?
                let frontFemale: String?
                let frontShiny: String?
                let frontShinyFemale: String?
            }
            
            struct OfficialArtworkSprites: Codable {
                let frontDefault: String?
                let frontShiny: String?
            }
            
            struct ShowdownSprites: Codable {
                let backDefault: String?
                let backFemale: String?
                let backShiny: String?
                let backShinyFemale: String?
                let frontDefault: String?
                let frontFemale: String?
                let frontShiny: String?
                let frontShinyFemale: String?
            }
        }
        
        struct VersionSprites: Codable {
            // Version sprites can have many nested structures with dynamic keys
            // We'll decode it flexibly to avoid errors with unknown version structures
            init(from decoder: Decoder) throws {
                // Use a single value container to decode the entire object
                // and then decode it as a dictionary to skip all nested structures
                let container = try decoder.singleValueContainer()
                // Try to decode as a dictionary - this will recursively decode all nested values
                if let dict = try? container.decode([String: JSONValue].self) {
                    // Successfully decoded, but we don't need to store it
                    _ = dict
                } else {
                    // If it's not a dictionary, it might be null or empty
                    // Just consume the value
                    _ = try? container.decode(JSONValue.self)
                }
            }
            
            func encode(to encoder: Encoder) throws {
                // Encoding not needed for API responses
                var container = encoder.singleValueContainer()
                try container.encode([String: String]())
            }
        }
        
        // Helper enum to decode any JSON value recursively
        private enum JSONValue: Codable {
            case string(String)
            case int(Int)
            case double(Double)
            case bool(Bool)
            case object([String: JSONValue])
            case array([JSONValue])
            case null
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if container.decodeNil() {
                    self = .null
                } else if let bool = try? container.decode(Bool.self) {
                    self = .bool(bool)
                } else if let int = try? container.decode(Int.self) {
                    self = .int(int)
                } else if let double = try? container.decode(Double.self) {
                    self = .double(double)
                } else if let string = try? container.decode(String.self) {
                    self = .string(string)
                } else if let array = try? container.decode([JSONValue].self) {
                    self = .array(array)
                } else if let object = try? container.decode([String: JSONValue].self) {
                    self = .object(object)
                } else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode JSONValue")
                }
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .string(let value): try container.encode(value)
                case .int(let value): try container.encode(value)
                case .double(let value): try container.encode(value)
                case .bool(let value): try container.encode(value)
                case .object(let value): try container.encode(value)
                case .array(let value): try container.encode(value)
                case .null: try container.encodeNil()
                }
            }
        }
    }
    
    struct PokemonStat: Codable {
        let baseStat: Int
        let effort: Int
        let stat: NamedAPIResource
    }
    
    struct PokemonType: Codable {
        let slot: Int
        let type: NamedAPIResource
    }
    
    struct NamedAPIResource: Codable {
        let name: String
        let url: String
    }
}

struct GetPokemonDetail {
    let id: Int
}

extension GetPokemonDetail: TargetType {
    
    var baseURL: URL {
        ApiConstant.baseUrl
    }
    
    var path: String {
        "pokemon/\(id)"
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

