//
//  Pokemon.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import UIKit

import PromiseKit
import Factory

class Pokemon {
    let number: Int
    let name: String
    let types: [PokemonType]
    let image: Promise<Data>
    
    var isCollected: Bool {
        get {
            return collectionService.isCollected(pokemonNumber: number)
        }
        set {
            collectionService.toggleCollection(pokemonNumber: number)
        }
    }
    
    let weight: Int
    let height: Int
    let hp: Int
    let defense: Int
    let attack: Int
    let speed: Int
    private let hdImageUrl: URL?
    @Injected(\.pokemonInfoService) private var pokemonInfoService: PokemonInfoService
    @Injected(\.collectionService) private var collectionService: CollectionService
    
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
    
    func getHdImage() -> Promise<Data> {
        guard let hdImageUrl else {
            return image
        }
        return pokemonInfoService.loadImage(from: hdImageUrl)
    }
    
    
}
