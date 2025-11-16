//
//  PokemonDetailView.swift
//  Pokemon
//
//  Created by Sean on 2025/11/16.
//

import SwiftUI
import PromiseKit

struct PokemonDetailView: View {
    let pokemon: Pokemon
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var imageData: Data?
    @State private var isLoadingImage = true
    @State private var isCollected: Bool
    
    init(pokemon: Pokemon) {
        self.pokemon = pokemon
        _isCollected = State(initialValue: pokemon.isCollected)
    }
    
    // 計算漸變顏色（根據 PokemonType 混合）
    private var gradientColors: [Color] {
        let types = pokemon.types
        if types.isEmpty {
            return [Color.gray, Color.gray]
        } else if types.count == 1 {
            let color = Color(types[0].color)
            return [color, color]
        } else {
            // 混合兩個類型的顏色
            let color1 = Color(types[0].color)
            let color2 = Color(types[1].color)
            return [color1, color2]
        }
    }
    
    // 計算縮放比例（根據滾動偏移）
    private var headerScale: CGFloat {
        let minScale: CGFloat = 0.8
        let maxOffset: CGFloat = 200
        let scale = 1.0 - (min(scrollOffset, maxOffset) / maxOffset) * (1.0 - minScale)
        return max(scale, minScale)
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    // 背景漸變（可縮放）
                    VStack {
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .cornerRadius(70, corners: .bottomLeft)
                        .cornerRadius(70, corners: .bottomRight)
                        .ignoresSafeArea()
                        .scaleEffect(headerScale, anchor: .top)
                        .frame(height: 180)
                        Spacer()
                    }
                    
                    ScrollView {
                        VStack {
                                Spacer()
                                .frame(height: 40)
                                // Pokemon 圖片
                                Group {
                                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } else {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.2))
                                            .overlay(
                                                ProgressView()
                                                    .tint(.white)
                                            )
                                    }
                                }
                                .frame(height: 250)
                                .padding(.horizontal, 40)
                                
                                // Pokemon 名稱
                                Text(pokemon.name.capitalized)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.top, 24)
                                
                                // Pokemon 類型
                                HStack(spacing: 12) {
                                    ForEach(pokemon.types, id: \.self) { type in
                                        Text(type.rawValue.capitalized)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color(type.color))
                                            .cornerRadius(20)
                                    }
                                }
                                
                                // 體重和身高
                                HStack(spacing: 40) {
                                    VStack(spacing: 4) {
                                        Text("\(String(format: "%.1f", Double(pokemon.weight) / 10.0)) KG")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.black)
                                        Text("Weight")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text("\(String(format: "%.1f", Double(pokemon.height) / 10.0)) M")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.black)
                                        Text("Height")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 16)
                                
                                // Base Stats
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Base Stats")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 20)
                                    
                                    VStack(spacing: 12) {
                                        StatRowView(label: "HP", value: pokemon.hp, maxValue: 255, color: .red)
                                        StatRowView(label: "ATK", value: pokemon.attack, maxValue: 255, color: .orange)
                                        StatRowView(label: "DEF", value: pokemon.defense, maxValue: 255, color: .blue)
                                        StatRowView(label: "SPD", value: pokemon.speed, maxValue: 255, color: .cyan)
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .padding(.bottom, 40)
                            }
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: -proxy.frame(in: .named("scroll")).minY)
                                }
                            )
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = -value
                    }
                }
                .navigationTitle(String(format: "#%03d", pokemon.number))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(String(format: "#%03d", pokemon.number))
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.black)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isCollected.toggle()
                            pokemon.isCollected = isCollected
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: 36, height: 36)
                                
                                Image(isCollected ? "redBall" : "grayBall")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                }
                .toolbarBackground(.clear, for: .navigationBar)
                .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
                .onAppear {
                    loadImage()
                    isCollected = pokemon.isCollected
                }
            }
        }
    }
    
    private func loadImage() {
        pokemon.getHdImage()
            .done { data in
                imageData = data
                isLoadingImage = false
            }
            .catch { error in
                isLoadingImage = false
            }
    }
}

// Stat Row View
struct StatRowView: View {
    let label: String
    let value: Int
    let maxValue: Int
    let color: Color
    
    private var progress: CGFloat {
        return CGFloat(value) / CGFloat(maxValue)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
                .frame(width: 40, alignment: .leading)
            
            Text("\(value)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 35, alignment: .trailing)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景條
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // 進度條
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
            
            Text("\(maxValue)")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .frame(width: 35, alignment: .leading)
        }
    }
}

// Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    // 需要一個示例 Pokemon 來預覽
    let samplePokemon = Pokemon(
        number: 3,
        name: "venusaur",
        types: [.grass, .poison],
        image: Promise.value(Data()),
        weight: 1000,
        height: 20,
        hp: 80,
        defense: 83,
        attack: 82,
        speed: 80,
        hdImageUrl: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/150.png")
    )
    return PokemonDetailView(pokemon: samplePokemon)
}

