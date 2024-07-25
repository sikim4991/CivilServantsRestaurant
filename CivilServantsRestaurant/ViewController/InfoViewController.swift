//
//  SettingViewController.swift
//  CivilServantsRestaurant
//
//  Created by SIKim on 5/2/24.
//

import UIKit
import StoreKit

class InfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var infoTableView: UITableView!
    
    private var informations: [Information] = [
        Information(
            title: "앱 평가하기",
            detail: nil
        ),
        Information(
            title: "앱 리뷰 작성하기",
            detail: nil
        ),
        Information(
            title: "데이터 출처",
            detail: "보기"
        ),
        Information(
            title: "현재 버전",
            detail: {
                //번들에서 현재 버전 가져옴
                guard let dictionary = Bundle.main.infoDictionary,
                      let version = dictionary["CFBundleShortVersionString"] as? String else { return "" }
                return version
            }()
        )
    ]
    // 데이터 출처 열었는지 여부
    private var isOpenDataSource: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.infoTableView.dataSource = self
        self.infoTableView.delegate = self
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        // 데이터 출처를 열었는지에 따라 섹션 수가 바뀜
        if isOpenDataSource {
            return 2
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        // 섹션에 따른 행의 개수
        // 0번 섹션은 정보 행의 개수만큼
        // 1번 섹션(데이터 출처 설명)은 1개
        // 나머지는 0개
        if section == 0 {
            return informations.count
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        // 각 섹션과 행에 따른 뷰 그리기
        if indexPath.section == 0 {
            content.text = informations[indexPath.row].title
            content.textProperties.font = .preferredFont(forTextStyle: .callout)
            if indexPath.row == 2 {
                content.secondaryText = isOpenDataSource ? "닫기" : "보기"
            } else {
                content.secondaryText = informations[indexPath.row].detail
            }
            content.secondaryTextProperties.font = .preferredFont(forTextStyle: .subheadline)
        } else if indexPath.section == 1 {
            content.text = "서울 열린데이터광장"
            content.textProperties.font = .preferredFont(forTextStyle: .callout)
            content.secondaryText = "바로가기"
            content.secondaryTextProperties.font = .preferredFont(forTextStyle: .subheadline)
        }
        
        // 셀에 설정(뷰) 적용, 눌렀을 때 색이 변하지않도록 스타일 = none
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        var content = cell?.defaultContentConfiguration()
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                // 앱 평가(별점) 남기기
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    DispatchQueue.main.async {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }
            } else if indexPath.row == 1 {
                // 앱 평가 작성하기
                var components = URLComponents(string: "https://apps.apple.com/app/id6505140535")
                components?.queryItems = [URLQueryItem(name: "action", value: "write-review")]
                
                guard let url = components?.url else { return }
                
                UIApplication.shared.open(url)
            } else if indexPath.row == 2 {
                // 데이터 출처 여닫기, 그에 따른 선택한 행 뷰 다시 그리기
                isOpenDataSource.toggle()
                
                content?.text = informations[indexPath.row].title
                content?.textProperties.font = .preferredFont(forTextStyle: .callout)
                content?.secondaryText = isOpenDataSource ? "닫기" : "보기"
                content?.secondaryTextProperties.font = .preferredFont(forTextStyle: .subheadline)
                
                cell?.contentConfiguration = content
                
                // 테이블 뷰 리로드 후, 애니메이션 적용
                // 해당 섹션 리로드만 했더니 오류 발생
                tableView.reloadData()
                if isOpenDataSource {
                    tableView.reloadSections(IndexSet(integer: 1), with: .fade)
                }
            }
        } else if indexPath.section == 1 {
            // 데이터 출처 주소로 이동
            guard let DataSourceURL = URL(string: "https://data.seoul.go.kr/dataList/OA-22156/S/1/datasetView.do") else { return }
            
            UIApplication.shared.open(DataSourceURL)
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // 푸터를 코드 베이스로 작성(programmatically)
        let uiView = UIView(frame: .init(x: 0, y: 0, width: tableView.frame.width, height: 0))
        let label = UILabel()
        // 섹션 경계선
        let divider = UIView()
        
        divider.backgroundColor = .systemGray5
        
        uiView.addSubview(divider)
        
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        if section == 1 {
            // 섹션 1에는 레이블 아래에 디바이더를 그리도록 오토레이아웃 적용
            if isOpenDataSource {
                label.text = "\'서울시 본청 업무추진비\'를 토대로 제일 최근 데이터를 추출해 지도로 제공합니다. 최대 250개의 데이터를 불러오지만 제공되는 주소가 정형화되어 있지 않아 불러오는 과정에서 몇 개의 데이터는 누락될 수 있습니다."
                label.font = .preferredFont(forTextStyle: .caption1)
                label.textColor = .lightGray
                label.numberOfLines = 0
                
                uiView.addSubview(label)
                
                label.translatesAutoresizingMaskIntoConstraints = false
                
                label.centerXAnchor.constraint(equalTo: uiView.centerXAnchor).isActive = true
                label.leadingAnchor.constraint(equalTo: uiView.leadingAnchor, constant: 16).isActive = true
                label.trailingAnchor.constraint(equalTo: uiView.trailingAnchor, constant: -16).isActive = true
                label.topAnchor.constraint(equalTo: uiView.topAnchor).isActive = true
                
                divider.leadingAnchor.constraint(equalTo: uiView.leadingAnchor, constant: 20).isActive = true
                divider.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
                divider.trailingAnchor.constraint(equalTo: uiView.trailingAnchor, constant: -20).isActive = true
                divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
            }
        } else {
            // 그 외에는 섹션 바로 아래에 디바이더 그리도록 오토레이아웃 적용
            divider.leadingAnchor.constraint(equalTo: uiView.leadingAnchor, constant: 20).isActive = true
            divider.centerYAnchor.constraint(equalTo: uiView.centerYAnchor).isActive = true
            divider.trailingAnchor.constraint(equalTo: uiView.trailingAnchor, constant: -20).isActive = true
            divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        return uiView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // 헤더를 코드 베이스로 작성(programmatically)
        let uiView = UIView(frame: .init(x: 0, y: 0, width: tableView.frame.width, height: 0))
        let label = UILabel()
        
        // 섹션별 레이블
        if section == 0 {
            label.text = "정보"
        } else if section == 1 {
            label.text = "자세히"
        }
        // 레이블 폰트
        label.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        uiView.addSubview(label)
        
        // 오토레이아웃 적용
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: uiView.leadingAnchor, constant: 24).isActive = true
        label.centerYAnchor.constraint(equalTo: uiView.centerYAnchor).isActive = true
        
        return uiView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 헤더 높이
        return 50
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
