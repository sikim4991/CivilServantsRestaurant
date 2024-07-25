//
//  WebViewController.swift
//  CivilServantsRestaurant
//
//  Created by SIKim on 5/21/24.
//

import UIKit
import WebKit
import SwiftSoup

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    var tempTabBarController: UIViewController?
    
    var currentLat: Double = 0
    var currentLng: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }
    
    func loadWeb(keyword: String) {
        Task {
            let placeURLString: String = "https://m.place.naver.com/place/\(await findAddressID(keyword: keyword))/home"
            let urlRequest: URLRequest = URLRequest(url: URL(string: placeURLString)!)
            // 네이버에서 장소 검색한 결과를 웹뷰로 보여줌
            webView.load(urlRequest)
            
            // 모달 내릴 때 지도를 원상복구 하기위해 모달을 띄운 뷰컨트롤러 임시저장
            // 맵뷰컨트롤러가 아닌 탭바컨트롤러에서 띄운 것으로 나옴
            tempTabBarController = presentingViewController
        }
    }
    
    func findAddressID(keyword: String) async -> String {
        // https://m.map.naver.com/search2/search.naver?query=\(keyword)
        // component로 url설정
        var urlComponent = URLComponents(string: "https://m.map.naver.com")!
        urlComponent.path = "/search2/search.naver"
        urlComponent.queryItems = [URLQueryItem(name: "query", value: keyword)]
        
        do {
            //url로 부터 데이터를 가져와서 string형태의 utf8타입으로 인코딩
            let (data, _) = try await URLSession.shared.data(from: urlComponent.url!)
            guard let html = String(data: data, encoding: .utf8) else { return "" }
            // document로 파싱, script type=text/javascript 쿼리 내의 element
            let doc: Document = try SwiftSoup.parse(html)
            let elements = try doc.select("script[type=text/javascript]")
            for element in elements {
                //html을 string형태로 저장
                let scriptString = try element.html()
                if scriptString.contains("var searchResult = ") {
                    // from과 to 사이의 문자열을 저장
                    if let jsonString = scriptString.slice(from: "var searchResult = ", to: ";") {
                        let jsonData = jsonString.data(using: .utf8)!
                            do {
                                //json 데이터를 [String: Any], 즉 dictionary형태로 변환하여 저장
                                if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                    // site, list value 반환해서 저장
                                    if let site = json["site"] as? [String: Any],
                                       let list = site["list"] as? [[String: Any]] {
                                        for item in list {
                                            // 배열 중 id value 반환
                                            if let id = item["id"] as? String {
                                                return id
                                            }
                                        }
                                    }
                                }
                            } catch {
                                print("Error parsing JSON: \(error)")
                            }
                    }
                }
            }
        } catch{
            print("Error find address ID: \(error)")
        }
        return ""
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        guard let tabBarController = tempTabBarController as? TabBarController else {
            //            print("presentingViewControlelr Error")
            return
        }
        
        guard let viewControllers = tabBarController.viewControllers else {
            return
        }
        
        for viewController in viewControllers {
            guard let mapViewController = viewController as? MapViewController else {
                return
            }
            
            // 네이버 지도 크기 원상복구 및 카메라 정중앙으로 이동
            mapViewController.naverMapView.mapView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            mapViewController.moveCenterCamera(lat: currentLat, lng: currentLng)
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

extension String {
    func slice(from: String, to: String) -> String? {
        // from 문자열이 존재하면 해당 범위의 끝부분을 start로
        return (range(of: from)?.upperBound).flatMap { start in
            // to 문자열이 존재하면 해당 범위의 시작부분을 end로
            (range(of: to, range: start..<endIndex)?.lowerBound).map { end in
                String(self[start..<end])
            }
        }
    }
}
