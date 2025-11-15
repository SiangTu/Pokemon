//
//  TypeButtonCell.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import UIKit
import SnapKit

class TypeButtonCell: UICollectionViewCell {
    private let button = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with type: TypeListResponse.TypeResult) {
        button.setTitle(type.name.capitalized, for: .normal)
        button.backgroundColor = typeColor(for: type.name)
        button.setTitleColor(.white, for: .normal)
    }
    
    private func typeColor(for typeName: String) -> UIColor {
        switch typeName.lowercased() {
        case "normal": return .systemGray
        case "fighting": return .systemRed
        case "flying": return .systemBlue
        case "poison": return .purple
        case "ground": return .brown
        case "rock": return .systemGray
        case "bug": return .systemGreen
        case "ghost": return .purple
        case "steel": return .systemGray2
        case "fire": return .systemRed
        case "water": return .systemBlue
        case "grass": return .systemGreen
        case "electric": return .systemYellow
        case "psychic": return .systemPink
        case "ice": return .cyan
        case "dragon": return .systemPurple
        case "dark": return .black
        case "fairy": return .systemPink
        default: return .systemGray3
        }
    }
}

