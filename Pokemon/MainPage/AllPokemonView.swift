//
//  AllPokemonView.swift
//  Pokemon
//
//  Created by Sean on 2025/11/16.
//

import SwiftUI

struct AllPokemonView: View {
    @StateObject private var viewModel = AllPokemonViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.949, green: 0.949, blue: 0.969)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.pokemons.enumerated()), id: \.element.number) { index, pokemon in
                            PokemonRowView(pokemon: pokemon)
                                .onAppear {
                                    // 當倒數第 3 個 item 出現時，開始載入更多
                                    if index >= viewModel.pokemons.count - 3 {
                                        viewModel.loadMorePokemons()
                                    }
                                }
                        }
                        
                        // Loading indicator
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                        
                        // No more data indicator
                        if !viewModel.hasMore && !viewModel.pokemons.isEmpty {
                            Text("No more Pokémon")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .refreshable {
                    viewModel.refresh()
                }
            }
            .navigationTitle("All Pokémon")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                }
            }
            .toolbarBackground(.white.opacity(0.1), for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .onAppear {
                setNavigationBar()
                if viewModel.pokemons.isEmpty {
                    viewModel.loadMorePokemons()
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

struct PokemonRowView: View {
    let pokemon: Pokemon
    @State private var imageData: Data?
    @State private var isLoadingImage = true
    
    var body: some View {
        HStack(spacing: 12) {
            // Pokemon Image
            Group {
                if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(Color.gray.opacity(0.2))
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                                .opacity(isLoadingImage ? 1 : 0)
                        )
                }
            }
            .frame(width: 60, height: 60)
            .background(Color.white)
            .cornerRadius(8)
            
            // Pokemon Info
            VStack(alignment: .leading, spacing: 4) {
                Text(pokemon.name.capitalized)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                Text("#\(pokemon.number)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                // Types
                HStack(spacing: 4) {
                    ForEach(pokemon.types.prefix(2), id: \.self) { type in
                        Text(type.rawValue.capitalized)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(type.color))
                            .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
            
            // Pokeball Icon
            Image(systemName: pokemon.isCollected ? "checkmark.circle.fill" : "circle.fill")
                .foregroundColor(pokemon.isCollected ? .red : .gray)
                .font(.system(size: 24))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        pokemon.image
            .done { data in
                imageData = data
                isLoadingImage = false
            }
            .catch { error in
                isLoadingImage = false
                print("Failed to load image: \(error.localizedDescription)")
            }
    }
}

#Preview {
    AllPokemonView()
}

