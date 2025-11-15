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
    
    func configure(with type: PokemonType) {
        button.setTitle(type.rawValue.capitalized, for: .normal)
        button.backgroundColor = type.color
        button.setTitleColor(.white, for: .normal)
    }
}

