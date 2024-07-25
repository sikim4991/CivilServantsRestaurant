//
//  FavoritesViewController.swift
//  CivilServantsRestaurant
//
//  Created by SIKim on 7/13/24.
//

import UIKit
import NMapsMap

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NMFMapViewTouchDelegate {
    // custom tableview
    @IBOutlet weak var favoritesTableView: UITableView!
    
    // 비어있을 때 label view
    let emptyLabelView = EmptyLabelView()
    
    // 이전에 tap한 행 저장, 최대 50개 이므로 0이 아닌 50으로 초기화
    var selectedIndex: Int = 50
    // row가 열렸는지
    var isOpenRow: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // DataSource, Delegate 연결
        favoritesTableView.dataSource = self
        favoritesTableView.delegate = self
        
        // 비어있을 때 레이블 세팅
        emptyLabelView.setEmptyView()
        emptyLabelView.translatesAutoresizingMaskIntoConstraints = false
        
        // 레이블 뷰 추가
        view.addSubview(emptyLabelView)
        
        // 오토레이아웃 설정 및 활성화
        emptyLabelView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        emptyLabelView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        emptyLabelView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        emptyLabelView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 행 개수
        guard let tabBarController = tabBarController as? TabBarController else {
            return 0
        }
        return tabBarController.myFavorites?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCell", for: indexPath) as! FavoritesListViewCell
        
        cell.selectionStyle = .none
        
        guard let tabBarController = tabBarController as? TabBarController else {
            return cell
        }
        
        guard let myFavorites = tabBarController.myFavorites else {
            return cell
        }
        
        // Relaod를 대비해 프로퍼티 초기화
        selectedIndex = 50
        isOpenRow = false
        
        // row가 열렸을 때 그려지는 뷰들 삭제, 비활성화했던 오토레이아웃 활성화
        cell.subviews.forEach { subview in
            if subview.tag > 0 {
                subview.removeFromSuperview()
                cell.categoryBottomConstraint.isActive = true
            }
        }
        
        // Reload를 대비한 row뷰 초기 세팅
        cell.buttonImageView.image = UIImage(systemName: "chevron.compact.down")
        cell.buttonImageView.tintColor = .governmentNavy
        cell.titleLabel.text = myFavorites[indexPath.row].title
        cell.titleLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        cell.categoryLabel.text = myFavorites[indexPath.row].category
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FavoritesListViewCell
        guard let tabBarController = tabBarController as? TabBarController else { return }
        guard let myFavorites = tabBarController.myFavorites else { return }
        
        // 이전 선택 row랑 현재 선택 row가 같고 row가 열려있을 때
        if selectedIndex == indexPath.row && isOpenRow == true {
            // 해당 row를 닫음 ( 뷰 삭제 )
            cell.subviews.forEach { subview in
                if subview.tag == indexPath.row + 1 {
                    subview.removeFromSuperview()
                }
            }
            
            isOpenRow = false
            
            cell.categoryBottomConstraint.isActive = true
            cell.buttonImageView.image = UIImage(systemName: "chevron.compact.down")
        } else {
            // 해당 장소 마커 프로퍼티 초기화
            let marker = NMFMarker(position: NMGLatLng(lat: Double(myFavorites[indexPath.row].mapy)! * 0.0000001, lng: Double(myFavorites[indexPath.row].mapx)! * 0.0000001))
            // '지도'탭으로 이동하는 액션
            let moveMap = UIAction { _ in
                // '지도' 탭으로 선택된 것을 표시 (레이블)
                tabBarController.tabBar.items?.forEach({
                    switch $0.tag {
                    case 0:
                        $0.title = "●"
                    case 1:
                        $0.title = "목록"
                    case 2:
                        $0.title = "즐겨찾기"
                    case 3:
                        $0.title = "정보"
                    default:
                        break
                    }
                })
                
                // '지도'탭 이동
                tabBarController.selectedIndex = 0
                
                if let viewControllers = tabBarController.viewControllers {
                    viewControllers.forEach { viewController in
                        // MapViewController 옵셔널 바인딩
                        if let mapViewController = viewController as? MapViewController {
                            // 이전에 즐겨찾기 마커가 찍혀있을 수 있으니 삭제
                            mapViewController.favoriteMarker?.mapView = nil
                            // 즐겨찾기 해당 장소로 마커 초기화
                            mapViewController.favoriteMarker = NMFMarker(position: NMGLatLng(lat: Double(myFavorites[indexPath.row].mapy)! * 0.0000001, lng: Double(myFavorites[indexPath.row].mapx)! * 0.0000001), iconImage: NMF_MARKER_IMAGE_BLUE)
                            // 마커 사이즈
                            mapViewController.favoriteMarker?.width = 25
                            mapViewController.favoriteMarker?.height = 33
                            
                            // 카메라 이동
                            mapViewController.moveCenterCamera(lat: Double(myFavorites[indexPath.row].mapy)! * 0.0000001, lng: Double(myFavorites[indexPath.row].mapx)! * 0.0000001)
                            
                            // 즐겨찾기 마커 터치 핸들러 설정
                            mapViewController.favoriteMarker?.touchHandler = { _ in
                                
                                if self.presentedViewController != nil {
                                    // 마커 좌표로 카메라 이동
                                    mapViewController.moveCenterCamera(lat: (mapViewController.favoriteMarker?.position.lat)!, lng: (mapViewController.favoriteMarker?.position.lng)!)
                                } else {
                                    // 스토리보드에 있는 WebViewController 저장
                                    mapViewController.webViewController = mapViewController.storyboard!.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController
                                    
                                    // 네이버 맵뷰 사이즈 상단으로 절반 축소
                                    mapViewController.naverMapView.mapView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIScreen.main.bounds.height * 0.45, right: 0)
                                    
                                    // 마커 좌표로 카메라 이동
                                    mapViewController.moveCenterCamera(lat: (mapViewController.favoriteMarker?.position.lat)!, lng: (mapViewController.favoriteMarker?.position.lng)!)
                                    
                                    // 모달 시트 절반과 제일 위로 올릴 수 있게 함
                                    mapViewController.webViewController?.sheetPresentationController?.detents = [.medium(), .large()]
                                    // 시트 절반만 올려도 뒤 화면은 어두워지지 않게 설정
                                    mapViewController.webViewController?.sheetPresentationController?.largestUndimmedDetentIdentifier = .medium
                                    // 시트 상단 손잡이 생성
                                    mapViewController.webViewController?.sheetPresentationController?.prefersGrabberVisible = true
                                    
                                    // 모달 시트 띄우기
                                    mapViewController.present(mapViewController.webViewController!, animated: true)
                                }
                                
                                // 장소 이름 보여주기 및 사이즈 키우기
                                mapViewController.favoriteMarker?.captionText = cell.titleLabel.text!
                                mapViewController.favoriteMarker?.width = CGFloat(NMF_MARKER_SIZE_AUTO)
                                mapViewController.favoriteMarker?.height = CGFloat(NMF_MARKER_SIZE_AUTO)
                                
                                // 나머지 마커들 초기화
                                mapViewController.markers?.forEach({ marker in
                                    marker.setMarkerIcon()
                                    marker.marker.captionText = ""
                                })
                                
                                // 해당 장소 웹뷰에서 검색
                                mapViewController.webViewController?.loadWeb(keyword: cell.titleLabel.text!)
                                
                                // 해당 장소 좌표 저장
                                mapViewController.webViewController?.currentLat = (mapViewController.favoriteMarker?.position.lat)!
                                mapViewController.webViewController?.currentLng = (mapViewController.favoriteMarker?.position.lng)!
                                return true
                            }
                            mapViewController.favoriteMarker?.mapView = mapViewController.naverMapView.mapView
                        }
                    }
                }
            }
            // 주소 공유 액션
            let share = UIAction { _ in
                // 주소 공유 뷰 띄우기
                let shareViewController = UIActivityViewController(activityItems: [myFavorites[indexPath.row].title, myFavorites[indexPath.row].address, myFavorites[indexPath.row].roadAddress], applicationActivities: nil)
                shareViewController.popoverPresentationController?.sourceView = self.view
                
                self.present(shareViewController, animated: true)
            }
            // 삭제 액션
            let delete = UIAction { _ in
                // 삭제할 것인지 확인할 AlertViewController
                let alertViewController = UIAlertController(title: "삭제", message: "이 장소를 즐겨찾기에서 삭제하시겠습니까?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
                    tabBarController.myFavorites?.remove(at: indexPath.row)
                    tabBarController.saveFavorites()
                    
                    // 즐겨찾기가 비어있으면 비어있음을 나타내는 레이블 뷰 그리기
                    if tabBarController.myFavorites?.isEmpty ?? true {
                        self.emptyLabelView.isHidden = false
                    } else {
                        self.emptyLabelView.isHidden = true
                    }
                    
                    tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                }
                
                alertViewController.addAction(cancelAction)
                alertViewController.addAction(deleteAction)
                
                self.present(alertViewController, animated: true)
            }
            
            // row 열렸을 때 뷰 세팅
            cell.setRowViewWhenOpenRow()
            
            // 해당 주소 텍스트 저장
            cell.addressLabel.text = myFavorites[indexPath.row].address
            cell.roadAddressLabel.text = myFavorites[indexPath.row].roadAddress
            
            // 지도에서 해당 위치로 카메라 이동 및 마커 표시
            cell.naverMapView.moveCamera(NMFCameraUpdate(scrollTo: NMGLatLng(lat: Double(myFavorites[indexPath.row].mapy)! * 0.0000001, lng: (Double(myFavorites[indexPath.row].mapx)! - 7000) * 0.0000001), zoomTo: 15))
            marker.mapView = cell.naverMapView
            
            // 버튼들 액션 등록
            cell.moveMapButton.addAction(moveMap, for: .touchUpInside)
            cell.shareButton.addAction(share, for: .touchUpInside)
            cell.deleteButton.addAction(delete, for: .touchUpInside)
            
            isOpenRow = true
            
            // 태그 지정으로 subview 삭제할 수 있도록 함
            cell.addressLabel.tag = indexPath.row + 1
            cell.roadAddressLabel.tag = indexPath.row + 1
            cell.naverMapView.tag = indexPath.row + 1
            cell.moveMapButton.tag = indexPath.row + 1
            cell.shareButton.tag = indexPath.row + 1
            cell.deleteButton.tag = indexPath.row + 1
            
            cell.buttonImageView.image = UIImage(systemName: "chevron.compact.up")
        }
        
        // 이전 row를 저장
        selectedIndex = indexPath.row
        
        // tableview 업데이트
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FavoritesListViewCell
        
        // 선택해제된 row 닫기 ( 태그 지정한 subview 삭제 )
        cell.subviews.forEach { subview in
            if subview.tag == indexPath.row + 1 {
                subview.removeFromSuperview()
            }
        }
        
        // categoryLabel의 bottom 오토레이아웃 활성화
        cell.categoryBottomConstraint.isActive = true
        // 화살표 이미지 변경
        cell.buttonImageView.image = UIImage(systemName: "chevron.compact.down")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // row 열렸을 때와 닫혔을 때의 높이 설정
        if indexPath.row == selectedIndex && isOpenRow == true {
            return 288
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // tableview reload 및 즐겨찾기 비어있으면 레이블 나타냄
        self.favoritesTableView.reloadData()
        guard let tabBarController = tabBarController as? TabBarController else { return }
        if tabBarController.myFavorites?.isEmpty ?? true {
            emptyLabelView.isHidden = false
        } else {
            emptyLabelView.isHidden = true
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
