//
//  EmptyView.swift
//  CivilServantsRestaurant
//
//  Created by SIKim on 7/18/24.
//

import UIKit

// 즐겨찾기가 비어있을 때 보여줄 Label View
class EmptyLabelView: UIView {
    
    // 비어있음을 나타내는 레이블
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "즐겨찾기한 장소가 없습니다."
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 뷰 추가 및 오토레이아웃 설정, 활성화
    func setEmptyView() {
        addSubview(emptyLabel)
        
        emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
