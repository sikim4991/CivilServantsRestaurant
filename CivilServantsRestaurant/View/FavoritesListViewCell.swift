//
//  FavoritesListViewCell.swift
//  CivilServantsRestaurant
//
//  Created by SIKim on 7/13/24.
//

import UIKit
import NMapsMap

// '즐겨찾기'에서의 Custom View
class FavoritesListViewCell: UITableViewCell {
    // 스토리보드와 연결된 IBOutlet 프로퍼티 ( 기본 Cell View )
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var buttonImageView: UIImageView!
    @IBOutlet var categoryBottomConstraint: NSLayoutConstraint!
    
    // Row를 눌러서 열었을 때 그려질 프로퍼티 ( 열렸을 때 Cell View )
    var addressLabel: UILabel = UILabel()
    var roadAddressLabel: UILabel = UILabel()
    var naverMapView: NMFMapView = NMFMapView()
    var moveMapButton: UIButton = UIButton()
    var shareButton: UIButton = UIButton()
    var deleteButton: UIButton = UIButton()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // Row를 열었을 때 View 그리기
    func setRowViewWhenOpenRow() {
        //주소 레이블
        addressLabel = {
            let label = UILabel()
            label.font = .preferredFont(forTextStyle: .footnote)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        // 도로명 주소 레이블
        roadAddressLabel = {
            let label = UILabel()
            label.font = .preferredFont(forTextStyle: .footnote)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        // 네이버 지도 레이블
        naverMapView = {
            let mapView = NMFMapView()
            mapView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
            mapView.isStopGestureEnabled = false
            mapView.isTiltGestureEnabled = false
            mapView.isZoomGestureEnabled = false
            mapView.isRotateGestureEnabled = false
            mapView.isScrollGestureEnabled = false
            mapView.translatesAutoresizingMaskIntoConstraints = false
            return mapView
        }()
        
        // '지도'탭 이동 버튼
        moveMapButton = {
            let button = UIButton()
            button.setImage(UIImage(systemName: "paperplane"), for: .normal)
            button.tintColor = .white
            button.backgroundColor = .governmentNavy
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.white.cgColor
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        // 주소 공유 버튼
        shareButton = {
            let button = UIButton()
            button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
            button.tintColor = .white
            button.backgroundColor = .governmentNavy
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.white.cgColor
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        // 삭제 버튼
        deleteButton = {
            let button = UIButton()
            button.setImage(UIImage(systemName: "trash"), for: .normal)
            button.backgroundColor = .governmentRed
            button.tintColor = .white
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.white.cgColor
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        // 버튼 너비
        let buttonWidth = (self.bounds.width - self.layoutMargins.left - self.layoutMargins.right) / 3.0
        
        // cell의 bottom과 categoryLabel의 bottom이 연결된 오토레이아웃 설정 비활성화
        self.categoryBottomConstraint.isActive = false
        
        // 각 뷰들 추가
        self.addSubview(addressLabel)
        self.addSubview(roadAddressLabel)
        self.addSubview(naverMapView)
        self.addSubview(moveMapButton)
        self.addSubview(shareButton)
        self.addSubview(deleteButton)
        
        // 각 뷰들 오토레이아웃 설정 및 활성화
        addressLabel.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        addressLabel.topAnchor.constraint(equalTo: self.categoryLabel.bottomAnchor, constant: 6).isActive = true
        addressLabel.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        addressLabel.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        
        roadAddressLabel.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        roadAddressLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor).isActive = true
        roadAddressLabel.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        roadAddressLabel.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        
        naverMapView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        naverMapView.topAnchor.constraint(equalTo: roadAddressLabel.bottomAnchor, constant: 8).isActive = true
        naverMapView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        naverMapView.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
        
        moveMapButton.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        moveMapButton.topAnchor.constraint(equalTo: naverMapView.bottomAnchor).isActive = true
        moveMapButton.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        moveMapButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        
        shareButton.leadingAnchor.constraint(equalTo: moveMapButton.trailingAnchor).isActive = true
        shareButton.topAnchor.constraint(equalTo: naverMapView.bottomAnchor).isActive = true
        shareButton.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        shareButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        
        deleteButton.topAnchor.constraint(equalTo: naverMapView.bottomAnchor).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
    }
}
