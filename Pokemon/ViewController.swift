//
//  ViewController.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import UIKit
import SnapKit
import SwiftUI

class ViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Section 1: Featured Pokémon
    private let featuredSectionView = UIView()
    private let featuredTitleLabel = UILabel()
    private let featuredSeeMoreLabel = UILabel()
    private lazy var featuredCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(PokemonStackCell.self, forCellWithReuseIdentifier: "PokemonStackCell")
        return cv
    }()
    
    private var pokemonColumns: [[Pokemon]] = []
    
    // Section 2: Types
    private let typesSectionView = UIView()
    private let typesTitleLabel = UILabel()
    private let typesSeeMoreLabel = UILabel()
    private lazy var typesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(TypeButtonCell.self, forCellWithReuseIdentifier: "TypeButtonCell")
        return cv
    }()
    
    // Section 3: Regions
    private let regionsSectionView = UIView()
    private let regionsTitleLabel = UILabel()
    private let regionsSeeMoreLabel = UILabel()
    private let regionsStackView = UIStackView()
    
    private let viewModel = MainViewModel()
    private var pokemonList: [Pokemon] = []
    private var typeList: [PokemonType] = []
    private var regionList: [Region] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        view.backgroundColor = #colorLiteral(red: 0.9490135312, green: 0.9490135312, blue: 0.9694761634, alpha: 1)
        
        // Setup ScrollView
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Setup Title
        let titleLabel = UILabel()
        titleLabel.text = "Pokédex"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview()
        }
        
        // Setup Featured Pokémon Section
        setupFeaturedSection()
        
        // Setup Types Section
        setupTypesSection()
        
        // Setup Regions Section
        setupRegionsSection()
        
        // Layout constraints
        featuredSectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview()
        }
        
        typesSectionView.snp.makeConstraints { make in
            make.top.equalTo(featuredSectionView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
        }
        
        regionsSectionView.snp.makeConstraints { make in
            make.top.equalTo(typesSectionView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupFeaturedSection() {
        contentView.addSubview(featuredSectionView)
        
        // Title
        featuredTitleLabel.text = "Featured Pokémon"
        featuredTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        featuredSectionView.addSubview(featuredTitleLabel)
        
        featuredTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        // See More
        featuredSeeMoreLabel.text = "See more"
        featuredSeeMoreLabel.font = .systemFont(ofSize: 16)
        featuredSeeMoreLabel.textColor = .systemBlue
        featuredSeeMoreLabel.isUserInteractionEnabled = true
        let seeMoreTapGesture = UITapGestureRecognizer(target: self, action: #selector(seeMoreTapped))
        featuredSeeMoreLabel.addGestureRecognizer(seeMoreTapGesture)
        featuredSectionView.addSubview(featuredSeeMoreLabel)
        
        featuredSeeMoreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(featuredTitleLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        // Collection View
        featuredSectionView.addSubview(featuredCollectionView)
        
        featuredCollectionView.snp.makeConstraints { make in
            make.top.equalTo(featuredTitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(260)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupTypesSection() {
        contentView.addSubview(typesSectionView)
        
        // Title
        typesTitleLabel.text = "Types"
        typesTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        typesSectionView.addSubview(typesTitleLabel)
        
        typesTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        // See More
        typesSeeMoreLabel.text = "See more"
        typesSeeMoreLabel.font = .systemFont(ofSize: 16)
        typesSeeMoreLabel.textColor = .systemBlue
        typesSectionView.addSubview(typesSeeMoreLabel)
        
        typesSeeMoreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(typesTitleLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        // Collection View
        typesSectionView.addSubview(typesCollectionView)
        
        typesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(typesTitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupRegionsSection() {
        contentView.addSubview(regionsSectionView)
        
        // Title
        regionsTitleLabel.text = "Regions"
        regionsTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        regionsSectionView.addSubview(regionsTitleLabel)
        
        regionsTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        // See More
        regionsSeeMoreLabel.text = "See more"
        regionsSeeMoreLabel.font = .systemFont(ofSize: 16)
        regionsSeeMoreLabel.textColor = .systemBlue
        regionsSectionView.addSubview(regionsSeeMoreLabel)
        
        regionsSeeMoreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(regionsTitleLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        // Stack View for Regions Grid
        regionsStackView.axis = .vertical
        regionsStackView.spacing = 12
        regionsStackView.distribution = .fillEqually
        regionsSectionView.addSubview(regionsStackView)
        
        regionsStackView.snp.makeConstraints { make in
            make.top.equalTo(regionsTitleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
        }
    }
    
    private func loadData() {
        // Load Pokemons
        viewModel.getPokemons()
            .done { [weak self] pokemons in
                guard let self = self else { return }
                self.pokemonList = pokemons
                // Group Pokemon into columns of 3
                self.pokemonColumns = pokemons.chunked(into: 3)
                self.featuredCollectionView.reloadData()
            }
            .catch { error in
                print("Failed to load Pokemons: \(error.localizedDescription)")
            }
        
        // Load Types
        viewModel.getTypes()
            .done { [weak self] types in
                guard let self = self else { return }
                self.typeList = types
                self.typesCollectionView.reloadData()
            }
            .catch { error in
                print("Failed to load Types: \(error.localizedDescription)")
            }
        
        // Load Regions
        viewModel.getRegions()
            .done { [weak self] regions in
                guard let self = self else { return }
                self.regionList = regions
                self.setupRegionsGrid()
            }
            .catch { error in
                print("Failed to load Regions: \(error.localizedDescription)")
            }
    }
    
    private func setupRegionsGrid() {
        // Clear existing views
        regionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create rows of 2
        let chunkedRegions = Array(regionList.prefix(6)).chunked(into: 2)
        
        for row in chunkedRegions {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 12
            rowStack.distribution = .fillEqually
            
            for region in row {
                let card = createRegionCard(region: region)
                rowStack.addArrangedSubview(card)
            }
            
            regionsStackView.addArrangedSubview(rowStack)
            rowStack.snp.makeConstraints { make in
                make.height.equalTo(100)
            }
        }
    }
    
    private func createRegionCard(region: Region) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.lightGray.cgColor
        
        let nameLabel = UILabel()
        nameLabel.text = region.name.capitalized
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        card.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        let locationLabel = UILabel()
        locationLabel.text = "\(region.numOfLoaction) Locations"
        locationLabel.font = .systemFont(ofSize: 14)
        locationLabel.textColor = .gray
        card.addSubview(locationLabel)
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        return card
    }
    
    @objc private func seeMoreTapped() {
        let allPokemonView = AllPokemonView()
            .navigationBarHidden(true)
        let hostingController = UIHostingController(rootView: allPokemonView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    private func navigateToDetail(pokemon: Pokemon) {
        let detailView = PokemonDetailView(pokemon: pokemon)
            .navigationBarHidden(true)
        let hostingController = UIHostingController(rootView: detailView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == featuredCollectionView {
            return pokemonColumns.count
        } else if collectionView == typesCollectionView {
            return typeList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == featuredCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonStackCell", for: indexPath) as! PokemonStackCell
            cell.configure(with: pokemonColumns[indexPath.item])
            cell.onPokemonTap = { [weak self] pokemon in
                self?.navigateToDetail(pokemon: pokemon)
            }
            return cell
        } else if collectionView == typesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TypeButtonCell", for: indexPath) as! TypeButtonCell
            cell.configure(with: typeList[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == featuredCollectionView {
            // Width for one column, height for 3 Pokemon cards: (180 * 3) + (12 * 2 spacing) = 564
            return CGSize(width: 280, height: 240)
        } else if collectionView == typesCollectionView {
            return CGSize(width: 100, height: 80)
        }
        return .zero
    }
}

