//
//  Restaurant.swift
//  CivilServantsRestaurant
//
//  Created by SIKim on 5/2/24.
//

import Foundation

/// 공무원 업무추진비 API 모델
struct BusinessExpensesAPI: Codable {
    let odExpense: OdExpense
}

struct OdExpense: Codable {
    let listTotalCount: Int
    let result: Result
    let businessExpense: [BusinessExpense]
    
    enum CodingKeys: String, CodingKey {
        case listTotalCount = "list_total_count"
        case result = "RESULT"
        case businessExpense = "row"
    }
}

struct Result: Codable {
    let code, message: String
    
    enum CodingKeys: String, CodingKey {
        case code = "CODE"
        case message = "MESSAGE"
    }
}

struct BusinessExpense: Codable, Equatable {
    let id, title, deptName, telNumber: String
    let writer, registDate, execYear, execMonth: String
    let url: String
    let category, deptFullName, execDate: String
    var execLocation: String
    let execPurpose, targetName, paymentMethod, execAmount: String
    let bimok: String
    
    enum CodingKeys: String, CodingKey {
        case id = "NID"
        case title = "TITLE"
        case deptName = "DEPT_NM"
        case telNumber = "TELNO"
        case writer = "WRITER"
        case registDate = "REGIST_DT"
        case execYear = "EXEC_YR"
        case execMonth = "EXEC_MONTH"
        case url = "URL"
        case category = "CATEGORY"
        case deptFullName = "DEPT_NM_FULL"
        case execDate = "EXEC_DT"
        case execLocation = "EXEC_LOC"
        case execPurpose = "EXEC_PURPOSE"
        case targetName = "TARGET_NM"
        case paymentMethod = "PAYMENT_METHOD"
        case execAmount = "EXEC_AMOUNT"
        case bimok = "BIMOK"
    }
    
    mutating func filteredLocation() {
        execLocation = execLocation.replacingOccurrences(of: "(주)", with: " ")
        execLocation = execLocation.replacingOccurrences(of: "주식회사", with: " ")
        execLocation = execLocation.replacingOccurrences(of: "(", with: " ")
        execLocation = execLocation.replacingOccurrences(of: ")", with: " ")
    }
}
