//
//  GetPokemonTypesUseCase.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//
import PromiseKit
import Factory

struct GetPokemonTypesUseCase {
    
    @Injected(\.pokemonInfoService) private var pokemonInfoService: PokemonInfoService
    
    func execute(limit: Int? = nil, offset: Int? = nil) -> Promise<[PokemonType]> {
        // 1. 調用 API 取得類型列表
        return pokemonInfoService.getTypeList(limit: limit, offset: offset)
            .map { typeListResponse -> [PokemonType] in
                // 2. 將 TypeResult 轉換成 PokemonType enum
                return typeListResponse.results.compactMap { typeResult -> PokemonType? in
                    // 使用 rawValue 初始化器轉換，如果轉換失敗則返回 nil（會被 compactMap 過濾掉）
                    return PokemonType(rawValue: typeResult.name)
                }
            }
    }
}
