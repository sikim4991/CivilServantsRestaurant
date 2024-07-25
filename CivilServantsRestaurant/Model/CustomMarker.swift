//
//  CustomMarker.swift
//  CivilServantsRestaurant
//
//  Created by SIKim on 5/6/24.
//

import Foundation
import NMapsMap

/// 지도에 표시될 마커 모델
struct CustomMarker {
    var visitCount: Int
    var marker: NMFMarker
    var subCaption: String {
        "방문기록: \(visitCount)번"
    }
    
    // 공무원이 같은 장소 방문한 횟수 증가시키는 메소드
    mutating func addVisitCount() {
        self.visitCount += 1
    }
    
    // 마커 세팅 메소드
    func setMarkerIcon() {
        if 2 < self.visitCount && self.visitCount < 5 {
            marker.iconImage = NMF_MARKER_IMAGE_YELLOW
        } else if 4 < self.visitCount {
            marker.iconImage = NMF_MARKER_IMAGE_RED
        }
        marker.width = 25
        marker.height = 33
    }
}
