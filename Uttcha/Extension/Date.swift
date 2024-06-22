//
//  Date.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/06.
//

import Foundation

extension Date {
    func string(withFormat format: String, locale: Locale = Locale(identifier: "ko_KR")) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
