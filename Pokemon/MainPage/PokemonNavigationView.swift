//
//  PokemonNavigationView.swift
//  Pokemon
//
//  Created by Sean on 2025/11/16.
//

import SwiftUI

// Environment Key for title and titleColor
struct PokemonNavigationTitleKey: EnvironmentKey {
    static let defaultValue: (title: String, color: Color) = ("", .black)
}

extension EnvironmentValues {
    var pokemonNavigationTitle: (title: String, color: Color) {
        get { self[PokemonNavigationTitleKey.self] }
        set { self[PokemonNavigationTitleKey.self] = newValue }
    }
}

struct PokemonNavigationView<Content: View>: View {
    
    let content: () -> Content
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.pokemonNavigationTitle) private var navigationTitle
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        NavigationView {
            content()
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(navigationTitle.title)
                            .foregroundColor(navigationTitle.color)
                            .font(.headline)
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.black)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        }
    }

}

// TODO: 這邊原理要了解一下 extension View不好
// Modifier to set title and color
extension View {
    func pokemonNavigationTitle(_ title: String, color: Color = .black) -> some View {
        self.environment(\.pokemonNavigationTitle, (title: title, color: color))
    }
}

#Preview {
    PokemonNavigationView {
        Color.white
    }
    .pokemonNavigationTitle("123", color: .black)
}
