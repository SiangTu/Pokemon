//
//  PokemonCardView.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import UIKit
import SnapKit

class PokemonCardView: UIView {
    private lazy var containerView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .center
        view.spacing = 8
        view.addArrangedSubview(imageView)
        view.addArrangedSubview(informationView)
        view.addArrangedSubview(pokeballImageView)
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
    
    private lazy var pokeballImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "circle.fill")
        view.tintColor = .lightGray
        view.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
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
        self.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with pokemon: PokemonListResponse.PokemonResult) {
        if let id = extractID(from: pokemon.url) {
            numberLabel.text = "#\(id)"
            nameLabel.text = pokemon.name.uppercased()
            
            // Use mock types based on Pokemon ID
            let mockTypes = getMockTypes(for: id)
            setupTypes(types: mockTypes)
        }
    }
    
    private func getMockTypes(for id: Int) -> [PokemonDetailResponse.PokemonType] {
        // Mock type data for first 9 Pokemon
        let mockTypeData: [Int: [String]] = [
            1: ["grass", "poison"],  // Bulbasaur
            2: ["grass", "poison"],  // Ivysaur
            3: ["grass", "poison"],  // Venusaur
            4: ["fire"],              // Charmander
            5: ["fire"],              // Charmeleon
            6: ["fire", "flying"],    // Charizard
            7: ["water"],             // Squirtle
            8: ["water"],             // Wartortle
            9: ["water"]              // Blastoise
        ]
        
        let typeNames = mockTypeData[id] ?? ["normal"]
        return typeNames.enumerated().map { index, typeName in
            let namedResource = PokemonDetailResponse.NamedAPIResource(
                name: typeName,
                url: "https://pokeapi.co/api/v2/type/\(index + 1)/"
            )
            return PokemonDetailResponse.PokemonType(
                slot: index + 1,
                type: namedResource
            )
        }
    }
    
    private func setupTypes(types: [PokemonDetailResponse.PokemonType]) {
        typesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for type in types.prefix(2) {
            let typeLabel = UILabel()
            typeLabel.text = type.type.name.capitalized
            typeLabel.font = .systemFont(ofSize: 10, weight: .medium)
            typeLabel.textColor = .white
            typeLabel.textAlignment = .center
            typeLabel.backgroundColor = typeColor(for: type.type.name)
            typeLabel.layer.cornerRadius = 8
            typeLabel.clipsToBounds = true
            
            typesStackView.addArrangedSubview(typeLabel)
            typeLabel.snp.makeConstraints { make in
                make.width.equalTo(50)
                make.height.equalTo(20)
            }
        }
    }
    
    private func typeColor(for typeName: String) -> UIColor {
        switch typeName.lowercased() {
        case "grass": return .systemGreen
        case "poison": return .purple
        case "fire": return .systemRed
        case "water": return .systemBlue
        case "normal": return .systemGray
        case "fighting": return .systemRed
        case "flying": return .systemBlue
        default: return .systemGray2
        }
    }
    
    private func extractID(from url: String) -> Int? {
        let components = url.components(separatedBy: "/")
        return components.dropLast().last.flatMap { Int($0) }
    }
}

