//
//  Pokemon.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import UIKit

import PromiseKit

struct Pokemon {
    let number: Int
    let name: String
    let types: [PokemonType]
    let image: Promise<Data>
    var isCollected: Bool
    let weight: Int
    let height: Int
    let hp: Int
    let defense: Int
    let attack: Int
    let speed: Int
}
