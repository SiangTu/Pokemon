//
//  PokemonStackCell.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import UIKit
import SnapKit

class PokemonStackCell: UICollectionViewCell {
    var onPokemonTap: ((Pokemon) -> Void)?

    private lazy var stackView: UIStackView = {
       let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .fillEqually
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .white
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 14))
        }
    }
    
    func configure(with pokemons: [Pokemon]) {
        // Clear existing views
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add up to 3 Pokemon cards
        for pokemon in pokemons.prefix(3) {
            let cardView = PokemonCardView()
            cardView.configure(with: pokemon)
            cardView.onTap = { [weak self] in
                self?.onPokemonTap?(pokemon)
            }
            stackView.addArrangedSubview(cardView)
            // Set fixed height for each card
            cardView.snp.makeConstraints { make in
                make.height.equalTo(100)
            }
        }
    }
}
