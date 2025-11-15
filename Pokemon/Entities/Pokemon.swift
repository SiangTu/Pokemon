//
//  Pokemon.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import UIKit

import PromiseKit

class Pokemon {
    let number: Int
    let name: String
    let types: [PokemonType]
    let image: Promise<Data>
    
    // TODO: 這邊也是別依賴Service
    var isCollected: Bool {
        get {
            return PokemonCollectionService.shared.isCollected(pokemonNumber: number)
        }
        set {
            PokemonCollectionService.shared.setCollected(newValue, pokemonNumber: number)
        }
    }
    let weight: Int
    let height: Int
    let hp: Int
    let defense: Int
    let attack: Int
    let speed: Int
    private let hdImageUrl: URL?
    
    init(number: Int, name: String, types: [PokemonType], image: Promise<Data>, weight: Int, height: Int, hp: Int, defense: Int, attack: Int, speed: Int, hdImageUrl: URL?) {
        self.number = number
        self.name = name
        self.types = types
        self.image = image
        self.weight = weight
        self.height = height
        self.hp = hp
        self.defense = defense
        self.attack = attack
        self.speed = speed
        self.hdImageUrl = hdImageUrl
    }
    
    // TODO: 這裡依賴Service不好
    func getHdImage() -> Promise<Data> {
        guard let hdImageUrl else {
            return image
        }
        return NetworkService.loadImage(from: hdImageUrl)
    }
    
    
}
