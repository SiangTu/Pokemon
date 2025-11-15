//
//  GetRegionsUseCase.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//
import PromiseKit

struct GetRegionsUseCase {
    func execute(limit: Int? = nil, offset: Int? = nil) -> Promise<[Region]> {
        // 1. 先取得 Region 列表
        return NetworkService.getRegionList(limit: limit, offset: offset)
            .then { listResponse -> Promise<[Region]> in
                // 2. 從列表中提取每個 Region 的 ID
                let regionPromises = listResponse.results.compactMap { regionResult -> Promise<Region>? in
                    guard let id = self.extractID(from: regionResult.url) else {
                        return nil
                    }
                    
                    // 3. 對每個 ID 調用 detail API，然後轉換成 Region 物件
                    return NetworkService.getRegionDetail(id: id)
                        .map { detailResponse in
                            // 4. 轉換成 Region 物件
                            return self.convertToRegion(detailResponse: detailResponse)
                        }
                }
                
                // 5. 等待所有 Promise 完成
                return when(fulfilled: regionPromises)
            }
    }
    
    // 從 URL 中提取 ID（最後一個 path）
    private func extractID(from url: String) -> Int? {
        let components = url.components(separatedBy: "/")
        return components.dropLast().last.flatMap { Int($0) }
    }
    
    // 將 RegionDetailResponse 轉換成 Region 物件
    private func convertToRegion(detailResponse: RegionDetailResponse) -> Region {
        return Region(
            name: detailResponse.name,
            numOfLoaction: detailResponse.locations.count
        )
    }
}
