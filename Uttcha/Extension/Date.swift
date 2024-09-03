//
//  Date.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/06.
//

import Foundation

extension Date {
    func toStringFromTemplate(_ template: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate(template)
        return dateFormatter.string(from: self)
    }
}
