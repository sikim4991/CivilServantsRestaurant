//
//  MapViewController.swift
//  CivilServantsRestaurant
//
//  Created by SIKim on 5/2/24.
//

import UIKit
import NMapsMap

class MapViewController: UIViewController, CLLocationManagerDelegate {
    // 네이버 지도
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    // 데이터 불러오기 버튼
    @IBOutlet weak var loadDataButton: UIButton!
    // 마커 갯수 표시
    @IBOutlet weak var markerCountLabel: UILabel!
    // Place holder
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // 마커 array
    var markers: [CustomMarker]?
    // 마커 갯수
    var markerCount: Int = 0
    // 즐겨찾기 마커
    var favoriteMarker: NMFMarker?
    // 장소 마지막 인덱스
    var placeEndIndex: Int = 0
    // 데이터 불러온 횟수
    var loadDataCount: Int = 0
    // 캐시 데이터 존재 유무
    var isExistCacheData: Bool = false
    
    // 위치 권한 설정을 위한 LocationManager
    let locationManager = CLLocationManager()
    // 지도 카메라 업데이트
    var cameraUpdate = NMFCameraUpdate()
    
    // 장소 정보 제공을 위한 Webview
    var webViewController: WebViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 네이버 지도 세팅
        setNaverMap()
        // 버튼 세팅
        setButton()
        // activityIndicator stop일때 숨기기
        activityIndicator.hidesWhenStopped = true
        
        // 탭바컨트롤러 옵셔널 바인딩
        guard let tabBarController = tabBarController as? TabBarController else {
//            print("Optional Unwrapping Error -> tabBarController")
            return
        }
        
        Task {
            // 로딩 시작 (PlaceHolder)
            startLoadingView(tabBarController: tabBarController)
            // 캐시 데이터 있는지, 최신 데이터인지 확인
            isExistCacheData = await tabBarController.compareCacheData()
            // 데이터 불러와서 세팅
            setLoadData(tabBarController: tabBarController)
        }
    }
    
    func setNaverMap() {
        // 카메라 좌표 설정
        cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.564214, lng: 127.001699))
        
        // 델리게이트 연결 및 사용자 위치 권한 요청
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // 네이버맵뷰 터치 델리게이트 연결
        naverMapView.mapView.touchDelegate = self
        
        // 사용자 위치 버튼 활성화
        naverMapView.showLocationButton = true
        
        // 카메라 위치 이동 및 줌 레벨만큼 확대
        naverMapView.mapView.moveCamera(cameraUpdate)
        naverMapView.mapView.zoomLevel = 10
    }
    
    func setButton() {
        // 데이터 불러오기 버튼 그리기
        loadDataButton.layer.borderWidth = 1
        loadDataButton.layer.borderColor = UIColor.systemGray5.cgColor
        loadDataButton.layer.shadowColor = UIColor.gray.cgColor
        loadDataButton.layer.shadowOpacity = 0.25
        loadDataButton.layer.shadowOffset = CGSize(width: 0, height: 0.25)
    }
    
    func setLoadData(tabBarController: TabBarController) {
        Task {
            // 로딩 뷰 시작 (PlaceHolder)
            startLoadingView(tabBarController: tabBarController)
            
            // 캐시 데이터 최신 유무
            if isExistCacheData {
                // 디스크 캐시 데이터 로드
                tabBarController.loadDataInDiskCache(page: loadDataCount)
            } else {
                // 공무원 업무추진비 데이터 로드
                await tabBarController.loadBusinessExpensesAPI()
                
                // 업무추진비 데이터 옵셔널 바인딩
                guard let businessExpenses = tabBarController.businessExpenses else {
//                    print("Optional Unwrapping Error -> businessExpenses")
                    return
                }
                
                for businessExpense in businessExpenses {
                    // 집행장소에 대한 검색 결과 로드
                    await tabBarController.loadSearchPlaceAPI(search: businessExpense.execLocation)
                }
                
                // 데이터 디스크 캐시 저장
                tabBarController.saveDataInDiskCache(page: loadDataCount)
            }
            
            // 장소들 옵셔널 바인딩
            guard let places = tabBarController.places else {
//                print("Optional Unwrapping Error -> places")
                return
            }
            
            // 제일 최근에 불러온 인덱스부터 마지막 인덱스까지
            for place in places[placeEndIndex..<places.endIndex] {
//                print("Place=============================================\(places.count)")
//                print(place)
                // 장소 이름
                let placeTitle = place.title
                // 장소 좌표
                let placePosition = NMGLatLng(lat: Double(place.mapy)! * 0.0000001, lng: Double(place.mapx)! * 0.0000001)
                
                // 마지막 인덱스 저장
                placeEndIndex = places.endIndex
                
                // 마커가 존재하면
                if markers != nil {
                    // 비교를 위한 마커 인덱스
                    var markerIndex: Int = 0
                    // 중복 장소 없음
                    var isSamePlace: Bool = false
                    
                    for marker in self.markers! {
                        // 같은 장소 이름과 좌표면 방문 횟수 증가, 중복 장소 true
                        if marker.marker.position == placePosition && marker.marker.userInfo["title"] as? String == placeTitle {
                            self.markers?[markerIndex].addVisitCount()
                            isSamePlace = true
                        }
                        // 인덱스 증가
                        markerIndex += 1
                    }
                    
                    // 중복 장소 없으면
                    if !isSamePlace {
                        // 마커 추가, 장소 이름 저장 및 마커 수 증가
                        markers?.append(CustomMarker(visitCount: 1, marker: NMFMarker(position: placePosition)))
                        markers?[markerIndex].marker.userInfo = ["title": placeTitle]
                        markerCount += 1
                    }
                } else {
                    // 마커 array 저장, 장소 이름 저장 및 마커 수 증가
                    markers = [CustomMarker(visitCount: 1, marker: NMFMarker(position: placePosition))]
                    markers?[markers?.startIndex ?? 0].marker.userInfo = ["title": placeTitle]
                    markerCount += 1
                }
            }
            // 로딩 뷰 끝 (PlaceHolder 사라짐)
            stopLoadingView(tabBarController: tabBarController)
            // 지도에 마커 세팅
            setMarker()
        }
    }
    
    func setMarker() {
        guard let markers else {
            return
        }
        
        for marker in markers {
            // 마커 세팅
            marker.setMarkerIcon()
            // 터치 이벤트에 대한 핸들러
            marker.marker.touchHandler = { _ in
                // 터치된 마커를 제외한 나머지 마커들
                for otherMarker in markers {
                    // 캡션텍스트 빈 문장 및 크기 설정
                    if otherMarker.marker.captionText != "" {
                        otherMarker.marker.captionText = ""
                        otherMarker.marker.width = 25
                        otherMarker.marker.height = 33
                    }
                }
                
                // 터치된 마커 캡션 및 크기 설정
                marker.marker.captionText = marker.marker.userInfo["title"] as! String
                marker.marker.subCaptionText = marker.subCaption
                marker.marker.subCaptionTextSize = 8
                marker.marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
                marker.marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
                
                // 띄워진 모달이 있으면
                if self.presentedViewController != nil {
                    // 마커 좌표로 카메라 이동
                    self.moveCenterCamera(lat: (marker.marker.position.lat), lng: marker.marker.position.lng)
                } else {
                    // 스토리보드에 있는 WebViewController 저장
                    self.webViewController = self.storyboard!.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController
                    
                    // 네이버 맵뷰 사이즈 상단으로 절반 축소
                    self.naverMapView.mapView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIScreen.main.bounds.height * 0.45, right: 0)
                    
                    // 마커 좌표로 카메라 이동
                    self.moveCenterCamera(lat: (marker.marker.position.lat), lng: marker.marker.position.lng)
                    
                    // 모달 시트 절반과 제일 위로 올릴 수 있게 함
                    self.webViewController?.sheetPresentationController?.detents = [.medium(), .large()]
                    // 시트 절반만 올려도 뒤 화면은 어두워지지 않게 설정
                    self.webViewController?.sheetPresentationController?.largestUndimmedDetentIdentifier = .medium
                    // 시트 상단 손잡이 생성
                    self.webViewController?.sheetPresentationController?.prefersGrabberVisible = true
                    
                    // 모달 시트 띄우기
                    self.present(self.webViewController!, animated: true)
                }
                
                // 해당 장소 웹뷰에서 검색
                self.webViewController?.loadWeb(keyword: marker.marker.userInfo["title"] as! String)
                
                // 해당 장소 좌표 저장
                self.webViewController?.currentLat = marker.marker.position.lat
                self.webViewController?.currentLng = marker.marker.position.lng
                
                // 즐겨찾기 마커 작게
                self.favoriteMarker?.captionText = ""
                self.favoriteMarker?.width = 25
                self.favoriteMarker?.height = 33
                self.favoriteMarker?.mapView = self.naverMapView.mapView
                
                return true
            }
            // 지도에 마커 표시
            marker.marker.mapView = self.naverMapView.mapView
        }
    }
    
    func startLoadingView(tabBarController: TabBarController) {
        // 데이터 불러오기 비활성화
        loadDataButton.setTitle("불러오는 중", for: .normal)
        loadDataButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
        loadDataButton.isEnabled = false
        
        // PlaceHolder
        activityIndicator.startAnimating()
        
        // 탭바 아이템 비활성화
        tabBarController.tabBar.items.map { items in
            for item in items {
                item.isEnabled = false
            }
        }
        
        self.view.layer.opacity = 0.8
        
        guard let markers else {
            return
        }
        
        // 마커 터치 이벤트 비활성화
        for marker in markers {
            marker.marker.touchHandler = nil
        }
    }
    
    func stopLoadingView(tabBarController: TabBarController) {
        // 데이터 불러온 횟수 증가
        loadDataCount += 1
        loadDataButton.setTitle("데이터 불러오기 \(loadDataCount) / 5", for: .normal)
        
        // 5번 이상 비활성화
        if loadDataCount > 4 {
            loadDataButton.isEnabled = false
        } else {
            loadDataButton.isEnabled = true
        }
        
        // PlaceHolder 끝
        activityIndicator.stopAnimating()
        
        // 탭바 아이템 활성화
        tabBarController.tabBar.items.map { items in
            for item in items {
                item.isEnabled = true
            }
        }
        
        self.view.layer.opacity = 1.0
        
        // 마커 갯수 표시
        markerCountLabel.text = "\(markerCount)개의 장소"
    }
    
    func moveCenterCamera(lat: Double, lng: Double) {
        // 좌표로 카메라 이동
        cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng), zoomTo: 17)
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 0.75
        naverMapView.mapView.moveCamera(cameraUpdate)
    }
    
    
    @IBAction func loadNextData(_ sender: Any) {
        guard let tabBarController = tabBarController as? TabBarController else {
//            print("Optional Unwrapping Error -> tabBarController")
            return
        }
        
        // 다음 50개 불러올 수 있도록 시작과 끝번호 저장
        tabBarController.startNumber += 50
        tabBarController.endNumber += 50
        
        // 제일 최근에 캐시에 저장한 데이터 인덱스가 다음 데이터로 불러올 인덱스 시작점보다 작으면
        if UserDefaults.standard.integer(forKey: "lastDataIndex") < tabBarController.startNumber {
            // 캐시 데이터 없음
            self.isExistCacheData = false
            // 캐시 데이터 인덱스 최신화
            UserDefaults.standard.set(tabBarController.endNumber, forKey: "lastDataIndex")
        }
        
        // 데이터 로드
        setLoadData(tabBarController: tabBarController)
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

extension MapViewController: NMFMapViewTouchDelegate {
    // 맵 터치 메소드
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        guard self.presentedViewController != nil else {
            // 모달 시트가 없을 때 마커 초기화
            if let markers {
                for marker in markers {
                    if marker.marker.captionText != "" {
                        marker.marker.captionText = ""
                        marker.marker.width = 25
                        marker.marker.height = 33
                        marker.marker.mapView = self.naverMapView.mapView
                    }
                }
            }
            
            // 즐겨찾기 마커 삭제
            self.favoriteMarker?.mapView = nil
            self.favoriteMarker = nil
            return
        }
        // 모달 시트 내리기
        self.dismiss(animated: true)
    }
}
