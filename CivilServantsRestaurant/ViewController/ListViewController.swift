//
//  ListTableViewController.swift
//  CivilServantsRestaurant
//
//  Created by SIKim on 5/2/24.
//

import UIKit
import NMapsMap

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var restaurantButton: UIButton!
    @IBOutlet weak var cafeButton: UIButton!
    @IBOutlet weak var etcButton: UIButton!
    @IBOutlet weak var placeTableView: UITableView!
    
    private var categoryNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DataSource, Delegate 연결
        placeTableView.dataSource = self
        placeTableView.delegate = self
        
        // 카테고리 버튼 세팅
        setButton()
    }
    
    
    // MARK: - Table view data source
    
    func setButton() {
        // 카테고리 버튼 세팅 ( 스토리보드에서 cornerRadius 설정이 되지 않아 뷰 설정을 여기서 함 )
        restaurantButton.setTitle("🍚 음식점", for: .normal)
        restaurantButton.tintColor = .label
        restaurantButton.backgroundColor = .white
        restaurantButton.layer.cornerRadius = 16
        restaurantButton.layer.borderWidth = 1
        restaurantButton.layer.borderColor = UIColor.systemGray5.cgColor
        restaurantButton.layer.shadowColor = UIColor.gray.cgColor
        restaurantButton.layer.shadowOpacity = 0.25
        restaurantButton.layer.shadowOffset = CGSize(width: 0, height: 0.25)
        
        cafeButton.setTitle("☕️ 카페", for: .normal)
        cafeButton.tintColor = .label
        cafeButton.backgroundColor = .white
        cafeButton.layer.cornerRadius = 16
        cafeButton.layer.borderWidth = 1
        cafeButton.layer.borderColor = UIColor.systemGray5.cgColor
        cafeButton.layer.shadowColor = UIColor.gray.cgColor
        cafeButton.layer.shadowOpacity = 0.25
        cafeButton.layer.shadowOffset = CGSize(width: 0, height: 0.25)
        
        etcButton.setTitle("그 외", for: .normal)
        etcButton.tintColor = .label
        etcButton.backgroundColor = .white
        etcButton.layer.cornerRadius = 16
        etcButton.layer.borderWidth = 1
        etcButton.layer.borderColor = UIColor.systemGray5.cgColor
        etcButton.layer.shadowColor = UIColor.gray.cgColor
        etcButton.layer.shadowOpacity = 0.25
        etcButton.layer.shadowOffset = CGSize(width: 0, height: 0.25)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //섹션 수
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let tabBarController = tabBarController as? TabBarController else {
//            print("Optional Unwrapping Error -> tabBarController")
            return 0
        }
        
        // 장소 중복 제거
        var filterPlace = tabBarController.places?.reduce(into: [Place](), { result, tempPlace in
            if !result.contains(where: { $0 == tempPlace}) {
                result.append(tempPlace)
            }
        })
        
        // 카테고리 버튼 탭에 따른 필터링
        switch categoryNumber {
        case 1:
            filterPlace = filterPlace?.filter({
                $0.category.contains("음식점") || $0.category.contains("양식") || $0.category.contains("분식") || $0.category.contains("한식") || $0.category.contains("술집") || $0.category.contains("일식") || $0.category.contains("중식") || $0.category.contains("뷔페") || $0.category.contains("식료품") || $0.category.contains("패밀리레스토랑") || $0.category.contains("도시락,컵밥") || $0.category.contains("고기") || $0.category.contains("해물,생선요리")
            })
        case 2:
            filterPlace = filterPlace?.filter({
                $0.category.contains("카페")
            })
        case 3:
            filterPlace = filterPlace?.filter({
                !($0.category.contains("음식점") || $0.category.contains("양식") || $0.category.contains("분식") || $0.category.contains("한식") || $0.category.contains("술집") || $0.category.contains("일식") || $0.category.contains("중식") || $0.category.contains("뷔페") || $0.category.contains("식료품") || $0.category.contains("패밀리레스토랑") || $0.category.contains("도시락,컵밥") || $0.category.contains("고기") || $0.category.contains("해물,생선요리") || $0.category.contains("카페"))
            })
        default:
            break
        }
        
        // 최종적으로 필터링된 장소의 개수 = 행의 개수
        return filterPlace?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlaceListViewCell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceListViewCell
        
        guard let tabBarController = tabBarController as? TabBarController else {
//            print("Optional Unwrapping Error -> tabBarController")
            return cell
        }
        
        // 장소 중복 제거
        var filterPlace = tabBarController.places?.reduce(into: [Place](), { result, tempPlace in
            if !result.contains(where: { $0 == tempPlace}) {
                result.append(tempPlace)
            }
        })
        
        // 카테고리 버튼 탭에 따른 필터링
        switch categoryNumber {
        case 1:
            filterPlace = filterPlace?.filter({
                $0.category.contains("음식점") || $0.category.contains("양식") || $0.category.contains("분식") || $0.category.contains("한식") || $0.category.contains("술집") || $0.category.contains("일식") || $0.category.contains("중식") || $0.category.contains("뷔페") || $0.category.contains("식료품") || $0.category.contains("패밀리레스토랑") || $0.category.contains("도시락,컵밥") || $0.category.contains("고기") || $0.category.contains("해물,생선요리")
            })
        case 2:
            filterPlace = filterPlace?.filter({
                $0.category.contains("카페")
            })
        case 3:
            filterPlace = filterPlace?.filter({
                !($0.category.contains("음식점") || $0.category.contains("양식") || $0.category.contains("분식") || $0.category.contains("한식") || $0.category.contains("술집") || $0.category.contains("일식") || $0.category.contains("중식") || $0.category.contains("뷔페") || $0.category.contains("식료품") || $0.category.contains("패밀리레스토랑") || $0.category.contains("도시락,컵밥") || $0.category.contains("고기") || $0.category.contains("해물,생선요리") || $0.category.contains("카페"))
            })
        default:
            break
        }
        
        // 최종적으로 필터링된 장소 셀에 그리기
        cell.titleLabel.text = filterPlace?[indexPath.row].title
        cell.titleLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        cell.categoryLabel.text = filterPlace?[indexPath.row].category
        cell.addressLabel.text = filterPlace?[indexPath.row].address
        cell.roadAddressLabel.text = filterPlace?[indexPath.row].roadAddress
        
        // 공유하기 액션
        let share = UIAction(title: "주소 공유하기", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            let shareViewController = UIActivityViewController(activityItems: [cell.titleLabel.text!, cell.addressLabel.text!, cell.roadAddressLabel.text!], applicationActivities: nil)
            shareViewController.popoverPresentationController?.sourceView = self.view
            
            self.present(shareViewController, animated: true)
        }
        
        // 즐겨찾기 액션
        let favorites = UIAction(title: "즐겨찾기 추가", image: UIImage(systemName: "heart")) { _ in
            var alertViewController = UIAlertController()
            var cancelAction = UIAlertAction()
            
            // 즐겨찾기가 nil이 아니면
            if let myFavorites = tabBarController.myFavorites {
                // 즐겨찾기 데이터가 50개 미만일 때
                if myFavorites.count < 50 {
                    // 이미 즐겨찾기에 있는 장소이면 취소
                    if myFavorites.contains(filterPlace![indexPath.row]) {
                        alertViewController = .init(title: nil, message: "이미 즐겨찾기한 장소입니다.", preferredStyle: .alert)
                        cancelAction = .init(title: "닫기", style: .cancel)
                    } else {
                        // 즐겨찾기 추가
                        alertViewController = .init(title: nil, message: "즐겨찾기에 추가되었습니다.", preferredStyle: .alert)
                        cancelAction = .init(title: "닫기", style: .cancel, handler: { _ in
                            tabBarController.myFavorites?.append(filterPlace![indexPath.row])
                            tabBarController.saveFavorites()
                        })
                    }
                } else {
                    // 즐겨찾기 취소
                    alertViewController = .init(title: "오류", message: "최대 50개의 장소만 추가할 수 있습니다.", preferredStyle: .alert)
                    cancelAction = .init(title: "닫기", style: .cancel)
                }
            } else {
                // nil이면 1개 추가
                alertViewController = .init(title: nil, message: "즐겨찾기에 추가되었습니다.", preferredStyle: .alert)
                cancelAction = .init(title: "닫기", style: .cancel, handler: { _ in
                    tabBarController.myFavorites = [filterPlace![indexPath.row]]
                    tabBarController.saveFavorites()
                })
            }
            
            alertViewController.addAction(cancelAction)
            
            self.present(alertViewController, animated: true)
        }
        
        // 메뉴버튼생성
        cell.othersButton.menu = UIMenu(identifier: .alignment, options: .displayInline, children: [favorites, share])
        cell.othersButton.showsMenuAsPrimaryAction = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 행의 높이
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 지도 탭으로 이동
        self.tabBarController?.selectedIndex = 0
        
        guard let tabBarController = tabBarController as? TabBarController else {
//            print("Optional Unwrapping Error -> tabBarController")
            return
        }
        
        //지도 탭으로 선택된 것을 표시 (레이블)
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
        
        guard let places = tabBarController.places else {
//            print("Optional Unwrapping Error -> places")
            return
        }
        
        guard let viewControllers = tabBarController.viewControllers else {
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? PlaceListViewCell else {
            return
        }
        
        // 해당하는 장소의 이름과 주소가 일치하는 데이터를 임시로 저장
        let tempData = places[places.firstIndex(where: { $0.title == cell.titleLabel.text && $0.address == cell.addressLabel.text }) ?? 0]
        
        for viewController in viewControllers {
            if let mapViewController = viewController as? MapViewController {
                // 해당 장소의 좌표로 이동
                mapViewController.moveCenterCamera(lat: Double(tempData.mapy)! * 0.0000001, lng: Double(tempData.mapx)! * 0.0000001)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.placeTableView.reloadData()
    }
    
    @IBAction func filteredRestaurant(_ sender: Any) {
        // 카테고리 선택되었을 때 해당 버튼과 나머지 버튼 뷰 그리기
        if categoryNumber != 1 {
            categoryNumber = 1
            restaurantButton.tintColor = .white
            restaurantButton.layer.backgroundColor = UIColor.governmentNavy.cgColor
            cafeButton.tintColor = .label
            cafeButton.layer.backgroundColor = UIColor.white.cgColor
            etcButton.tintColor = .label
            etcButton.layer.backgroundColor = UIColor.white.cgColor
        } else {
            categoryNumber = 0
            restaurantButton.tintColor = .label
            restaurantButton.layer.backgroundColor = UIColor.white.cgColor
        }
        // 섹션 리로드 (애니메이션 적용)
        self.placeTableView.reloadSections(IndexSet(integersIn: 0...placeTableView.numberOfSections - 1), with: .automatic)
    }
    
    @IBAction func filteredCafe(_ sender: Any) {
        // 카테고리 선택되었을 때 해당 버튼과 나머지 버튼 뷰 그리기
        if categoryNumber != 2 {
            categoryNumber = 2
            cafeButton.tintColor = .white
            cafeButton.layer.backgroundColor = UIColor.governmentNavy.cgColor
            restaurantButton.tintColor = .label
            restaurantButton.layer.backgroundColor = UIColor.white.cgColor
            etcButton.tintColor = .label
            etcButton.layer.backgroundColor = UIColor.white.cgColor
        } else {
            categoryNumber = 0
            cafeButton.tintColor = .label
            cafeButton.layer.backgroundColor = UIColor.white.cgColor
        }
        // 섹션 리로드 (애니메이션 적용)
        self.placeTableView.reloadSections(IndexSet(integersIn: 0...placeTableView.numberOfSections - 1), with: .automatic)
    }
    
    @IBAction func filteredEtc(_ sender: Any) {
        // 카테고리 선택되었을 때 해당 버튼과 나머지 버튼 뷰 그리기
        if categoryNumber != 3 {
            categoryNumber = 3
            etcButton.tintColor = .white
            etcButton.layer.backgroundColor = UIColor.governmentNavy.cgColor
            restaurantButton.tintColor = .label
            restaurantButton.layer.backgroundColor = UIColor.white.cgColor
            cafeButton.tintColor = .label
            cafeButton.layer.backgroundColor = UIColor.white.cgColor
        } else {
            categoryNumber = 0
            etcButton.tintColor = .label
            etcButton.layer.backgroundColor = UIColor.white.cgColor
        }
        // 섹션 리로드 (애니메이션 적용)
        self.placeTableView.reloadSections(IndexSet(integersIn: 0...placeTableView.numberOfSections - 1), with: .automatic)
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
