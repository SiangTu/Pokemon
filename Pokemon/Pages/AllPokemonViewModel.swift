//
//  AllPokemonViewModel.swift
//  Pokemon
//
//  Created by Sean on 2025/11/16.
//

import Foundation
import PromiseKit
import Combine

@MainActor
class AllPokemonViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    @Published var isLoading = false
    @Published var hasMore = true
    @Published var errorMessage: String?
    
    private let getPokemonsUseCase = GetPokemonsUseCase()
    private let pageSize = 20
    private var currentOffset = 0
    
    func loadMorePokemons() {
        guard !isLoading && hasMore else { return }
        
        isLoading = true
        errorMessage = nil
        
        getPokemonsUseCase.execute(limit: pageSize, offset: currentOffset)
            .done { [weak self] newPokemons in
                guard let self = self else { return }
                
                Task { @MainActor in
                    if newPokemons.isEmpty {
                        self.hasMore = false
                    } else {
                        self.pokemons.append(contentsOf: newPokemons)
                        self.currentOffset += newPokemons.count
                        // 如果返回的數量少於 pageSize，表示沒有更多資料了
                        if newPokemons.count < self.pageSize {
                            self.hasMore = false
                        }
                    }
                    
                    self.isLoading = false
                }
            }
            .catch { [weak self] error in
                guard let self = self else { return }
                Task { @MainActor in
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
    }
    
    func refresh() {
        pokemons.removeAll()
        currentOffset = 0
        hasMore = true
        loadMorePokemons()
    }
}

