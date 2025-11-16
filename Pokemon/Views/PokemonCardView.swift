//
//  PokemonCardView.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import UIKit
import SnapKit

class PokemonCardView: UIView {
    var onTap: (() -> Void)?
    
    private lazy var containerView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .center
        view.spacing = 8
        view.addArrangedSubview(imageView)
        view.addArrangedSubview(informationView)
        view.addArrangedSubview(pokeballButton)
        return view
    }()
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.snp.makeConstraints { make in
            make.width.height.equalTo(45)
        }
        view.layer.cornerRadius = 4
        view.backgroundColor = .gray
        return view
    }()
    
    private lazy var informationView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .leading
        view.spacing = 4
        view.addArrangedSubview(titleView)
        view.addArrangedSubview(typesStackView)
        return view
    }()
    
    private lazy var titleView: UIView = {
        let view = UIView()
        view.addSubview(numberLabel)
        numberLabel.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(numberLabel.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        return view
    }()
    
    private lazy var numberLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16, weight: .bold)
        return view
    }()
    
    private let nameLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16, weight: .bold)
        return view
    }()
    
    private lazy var typesStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 4
        return view
    }()
    
    private lazy var pokeballButton: UIButton = {
        let button = UIButton(type: .custom)
        button.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        button.addTarget(self, action: #selector(pokeballButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private weak var currentPokemon: Pokemon?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 添加點擊手勢
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }
    
    @objc private func handleTap() {
        onTap?()
    }
    
    func configure(with pokemon: Pokemon) {
        self.currentPokemon = pokemon
        numberLabel.text = "#\(pokemon.number)"
        nameLabel.text = pokemon.name.uppercased()
        setupTypes(types: pokemon.types)
        
        // 更新收藏狀態
        updateCollectionStatus(isCollected: pokemon.isCollected)
        
        // Load image from Promise
        pokemon.image
            .done { [weak self] imageData in
                guard let self = self, let image = UIImage(data: imageData) else { return }
                self.imageView.image = image
            }
            .catch { error in
                print("Failed to load image: \(error.localizedDescription)")
            }
    }
    
    @objc private func pokeballButtonTapped() {
        guard let pokemon = currentPokemon else { return }
        pokemon.isCollected = !pokemon.isCollected
        updateCollectionStatus(isCollected: pokemon.isCollected)
    }
    
    private func updateCollectionStatus(isCollected: Bool) {
        let imageName = isCollected ? "redBall" : "grayBall"
        pokeballButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    private func setupTypes(types: [PokemonType]) {
        typesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for type in types.prefix(2) {
            let typeLabel = UILabel()
            typeLabel.text = type.rawValue.capitalized
            typeLabel.font = .systemFont(ofSize: 10, weight: .medium)
            typeLabel.textColor = .white
            typeLabel.textAlignment = .center
            typeLabel.backgroundColor = type.color
            typeLabel.layer.cornerRadius = 8
            typeLabel.clipsToBounds = true
            
            typesStackView.addArrangedSubview(typeLabel)
            typeLabel.snp.makeConstraints { make in
                make.width.equalTo(50)
                make.height.equalTo(20)
            }
        }
    }
}

