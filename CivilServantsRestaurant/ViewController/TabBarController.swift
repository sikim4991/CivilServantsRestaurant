//
//  ViewController.swift
//  CivilServantsRestaurant
//
//  Created by SIKim on 5/1/24.
//

import UIKit
import NMapsMap

class TabBarController: UITabBarController {
    // 서울 열린 데이터 광장 인증 키
    let BusinessExpensesAPIAuthKey: String = 
    
    // 네이버 장소 검색 id, 암호
    let naverSearchPlaceClientId: String =
    let naverSearchPlaceClientSecret: String =
    
    // 데이터 캐싱을 위한 FileManager, UserDefaults
    let fileManager: FileManager = FileManager.default
    let userDefaults: UserDefaults = UserDefaults.standard
    
    // 오류 발생 시 안내를 위한 Alert
    var errorAlertController: UIAlertController = UIAlertController()
    let cancelAction: UIAlertAction = UIAlertAction(title: "닫기", style: .cancel)
    
    // 장소 데이터 array
    var places: [Place]?
    // 업무추진비 데이터 array
    var businessExpenses: [BusinessExpense]?
    
    // 업무추진비 API요청 시작과 끝번호
    var startNumber: Int = 1
    var endNumber: Int = 50
    
    //즐겨찾기 장소
    var myFavorites: [Place]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 탭바 세팅
        setTabBar()
        //즐겨찾기 로드
        loadFavorites()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // 선택된 tab item 표시
        tabBar.items?.forEach({
            switch $0.tag {
            case 0:
                $0.title = "지도"
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
        item.title = "●"
    }
    
    func setTabBar() {
        let appearance = UITabBarAppearance()
        
        // 탭바 배경 색상 변경
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .governmentNavy
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = tabBar.standardAppearance
    }
    
    func saveDataInDiskCache(page: Int) {
        // FileManager 경로 설정 프로퍼티
        let documentPath: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryPath: URL = documentPath.appendingPathComponent("placeData\(page)", conformingTo: .json)
        
        do {
            // 장소들 인코딩 후 디스크 캐시 저장
            let data = try JSONEncoder().encode(places)
            try data.write(to: directoryPath)
        } catch {
            // 오류 안내 Alert 띄우기
            errorAlertController = .init(title: "캐시 데이터 오류", message: "캐시 데이터를 저장하는 도중 오류가 발생했습니다.", preferredStyle: .alert)
            errorAlertController.addAction(cancelAction)
            
            self.present(errorAlertController, animated: false)
//            print("Save Cache Data Error -> \(error)")
        }
    }
    
    func loadDataInDiskCache(page: Int) {
        // FileManager 경로 설정 프로퍼티
        let documentPath: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryPath: URL = documentPath.appendingPathComponent("placeData\(page)", conformingTo: .json)
        
        do {
            // 디스크 경로에서 Data를 [Place] 타입으로 디코딩
            let data = try Data(contentsOf: directoryPath)
            let decodeData = try JSONDecoder().decode([Place].self, from: data)
            
            // 디코딩한 데이터를 places에 저장
            places = decodeData
        } catch {
            // 오류 안내 Alert 띄우기
            errorAlertController = .init(title: "캐시 데이터 오류", message: "캐시 데이터를 불러오는 도중 오류가 발생했습니다.", preferredStyle: .alert)
            errorAlertController.addAction(cancelAction)
            
            self.present(errorAlertController, animated: false)
//            print("Load Cache Data Error -? \(error)")
        }
    }
    
    func compareCacheData() async -> Bool {
        // 공무원 업무추진비 API 요청 url, 최신 데이터인지 확인을 위해 1번째 데이터만 요청
        //http://openapi.seoul.go.kr:8088/(인증키)/xml/odExpense/1/5/
        guard let url = URL(string: "http://openapi.seoul.go.kr:8088/\(BusinessExpensesAPIAuthKey)/json/odExpense/1/1/") else { return false }
        var request = URLRequest(url: url)
        
        businessExpenses = nil
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // API 요청
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // 요청한 데이터와 캐시 데이터 비교
            if userDefaults.data(forKey: "dataForComparing") == data {
                return true
            } else {
                // 다르거나 캐시 데이터가 없으면 캐시 데이터 업데이트
                userDefaults.set(data, forKey: "dataForComparing")
                // 몇번째 장소 데이터까지 디스크 캐시 저장했는지 확인하기 위해 endNumber 저장
                userDefaults.set(endNumber, forKey: "lastDataIndex")
                return false
            }
        } catch {
            // 오류 안내 Alert 띄우기
            errorAlertController = .init(title: "캐시 데이터 오류", message: "서버 점검 중이거나 캐시 데이터 확인 도중 오류가 발생했습니다.", preferredStyle: .alert)
            errorAlertController.addAction(cancelAction)
            
            self.present(errorAlertController, animated: false)
//            print(error)
            return false
        }
    }
    
    // 디스크에 저장된 즐겨찾기 데이터 불러오기
    func loadFavorites() {
        // 경로 설정
        let documentPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryPath = documentPath.appendingPathComponent("favorites", conformingTo: .json)
        
        do {
            // json 디코딩 후, myFavorites Array에 저장
            let data = try Data(contentsOf: directoryPath)
            let decodeData = try JSONDecoder().decode([Place].self, from: data)
            
            myFavorites = decodeData
        } catch {
            // 오류 안내 Alert 띄우기
            errorAlertController = .init(title: "데이터 오류", message: "데이터 로드 중 오류가 발생했습니다.", preferredStyle: .alert)
            errorAlertController.addAction(cancelAction)
            
            self.present(errorAlertController, animated: true)
        }
    }
    
    // 즐겨찾기 데이터 디스크에 저장하기
    func saveFavorites() {
        //경로 설정
        let documentPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryPath = documentPath.appendingPathComponent("favorites", conformingTo: .json)
        
        do {
            // json 형태로 인코딩 후, 디스크에 저장
            let data = try JSONEncoder().encode(myFavorites)
            try data.write(to: directoryPath)
        } catch {
            // 오류 안내 Alert 띄우기
            errorAlertController = .init(title: "데이터 오류", message: "데이터 저장 중 오류가 발생했습니다.", preferredStyle: .alert)
            errorAlertController.addAction(cancelAction)
            
            self.present(errorAlertController, animated: true)
        }
    }
    
    func loadBusinessExpensesAPI() async {
        // 공무원 업무추진비 API 요청 url, 50개씩 로드, 최대 250개
        //http://openapi.seoul.go.kr:8088/(인증키)/xml/odExpense/1/5/
        guard let url = URL(string: "http://openapi.seoul.go.kr:8088/\(BusinessExpensesAPIAuthKey)/json/odExpense/\(startNumber)/\(endNumber)/") else { return }
        var request = URLRequest(url: url)
        
        businessExpenses = nil
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // API 요청
            let (data, _) = try await URLSession.shared.data(for: request)
            // 요청한 데이터 디코딩
            let decodeData = try JSONDecoder().decode(BusinessExpensesAPI.self, from: data)
            decodeData.odExpense.businessExpense.forEach {
                // 장소 검색 정확도를 높이기 위해 프로퍼티에 저장
                var tempBusinessExpense = $0
                
                // 집행장소 필터링
                tempBusinessExpense.filteredLocation()
                
                // businessExpenses가 nil이면 array로 저장, 아니면 append로 추가
                if self.businessExpenses != nil {
                    businessExpenses?.append(tempBusinessExpense)
                } else {
                    businessExpenses = [tempBusinessExpense]
                }
            }
        } catch {
            // 오류 안내 Alert 띄우기
            errorAlertController = .init(title: "데이터 오류", message: "서버 점검 중이거나 데이터를 불러오는 도중 오류가 발생했습니다.", preferredStyle: .alert)
            errorAlertController.addAction(cancelAction)
            
            self.present(errorAlertController, animated: false)
//            print(error)
        }
    }
    
    func loadSearchPlaceAPI(search: String) async {
        // 네이버 검색 API 요청 url
        var urlComponents = URLComponents(string: "https://openapi.naver.com/v1/search/local.json")
        let query = URLQueryItem(name: "query", value: search)
        let displayQuery = URLQueryItem(name: "display", value: "1")
        let startQuery = URLQueryItem(name: "start", value: "1")
        let sortQuery = URLQueryItem(name: "sort", value: "random")
        urlComponents?.queryItems = [query, displayQuery, startQuery, sortQuery]
        
        guard let url = urlComponents?.url else {
//            print("Load Search Place API Request Error")
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue(naverSearchPlaceClientId, forHTTPHeaderField: "X-Naver-Client-Id")
        request.setValue(naverSearchPlaceClientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        do {
            // API 요청
            let (data, response) = try await URLSession.shared.data(for: request)
            // 빠르게 반복해서 API 요청하면 로드되지않아 지연
            try await Task.sleep(nanoseconds: 50000000)
            // 요청한 데이터 디코딩
            let decodeData = try JSONDecoder().decode(SearchPlaceAPI.self, from: data)
            
//            print("Search Result -> \(decodeData)")
//            print("Response         \(response)")
            for place in decodeData.items {
                // 장소 이름 필터링을 위해 다른 프로퍼티에 저장
                var tempPlaceData = place
                
                // 장소 이름 필터링
                tempPlaceData.filteredTitle()
                
                // places가 nil이면 array로 저장, 아니면 append로 추가
                if self.places != nil {
                    self.places?.append(tempPlaceData)
                } else {
                    self.places = [tempPlaceData]
                }
            }
        } catch {
            // 오류 안내 Alert 띄우기
            errorAlertController = .init(title: "검색 오류", message: "하루 검색 허용량이 초과되었거나 알 수 없는 오류가 발생했습니다.", preferredStyle: .alert)
            errorAlertController.addAction(cancelAction)
            
            self.present(errorAlertController, animated: false)
//            print(error)
        }
    }
}

