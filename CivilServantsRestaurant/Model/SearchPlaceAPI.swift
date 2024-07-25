//
//  SearchPlaceAPI.swift
//  CivilServantsRestaurant
//
//  Created by SIKim on 5/4/24.
//

import Foundation

///네이버 장소 검색 API 모델
struct SearchPlaceAPI: Codable {
    let lastBuildDate: String
    let total, start, display: Int
    let items: [Place]
}

struct Place: Codable, Equatable {
    var title: String
    let link: String
    let category, description, telephone, address: String
    let roadAddress, mapx, mapy: String
    
    //장소 이름 필터링
    mutating func filteredTitle() {
        title = title.replacingOccurrences(of: "<b>", with: "")
        title = title.replacingOccurrences(of: "</b>", with: "")
        title = title.replacingOccurrences(of: "amp;", with: "")
    }
}
