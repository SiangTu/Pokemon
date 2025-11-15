//
//  PokemonType+UIColor.swift
//  Pokemon
//
//  Created by Sean on 2025/11/16.
//

import UIKit

extension PokemonType {
    var color: UIColor {
        switch self {
        case .normal:
            return UIColor(red: 168/255, green: 168/255, blue: 120/255, alpha: 1.0)
        case .fighting:
            return UIColor(red: 192/255, green: 48/255, blue: 40/255, alpha: 1.0)
        case .flying:
            return UIColor(red: 168/255, green: 144/255, blue: 240/255, alpha: 1.0)
        case .poison:
            return UIColor(red: 160/255, green: 64/255, blue: 160/255, alpha: 1.0)
        case .ground:
            return UIColor(red: 224/255, green: 192/255, blue: 104/255, alpha: 1.0)
        case .rock:
            return UIColor(red: 184/255, green: 160/255, blue: 56/255, alpha: 1.0)
        case .bug:
            return UIColor(red: 168/255, green: 184/255, blue: 32/255, alpha: 1.0)
        case .ghost:
            return UIColor(red: 112/255, green: 88/255, blue: 152/255, alpha: 1.0)
        case .steel:
            return UIColor(red: 184/255, green: 184/255, blue: 208/255, alpha: 1.0)
        case .fire:
            return UIColor(red: 240/255, green: 128/255, blue: 48/255, alpha: 1.0)
        case .water:
            return UIColor(red: 104/255, green: 144/255, blue: 240/255, alpha: 1.0)
        case .grass:
            return UIColor(red: 120/255, green: 200/255, blue: 80/255, alpha: 1.0)
        case .electric:
            return UIColor(red: 248/255, green: 208/255, blue: 48/255, alpha: 1.0)
        case .psychic:
            return UIColor(red: 248/255, green: 88/255, blue: 136/255, alpha: 1.0)
        case .ice:
            return UIColor(red: 152/255, green: 216/255, blue: 216/255, alpha: 1.0)
        case .dragon:
            return UIColor(red: 112/255, green: 56/255, blue: 248/255, alpha: 1.0)
        case .dark:
            return UIColor(red: 112/255, green: 88/255, blue: 72/255, alpha: 1.0)
        case .fairy:
            return UIColor(red: 238/255, green: 153/255, blue: 172/255, alpha: 1.0)
        }
    }
}
