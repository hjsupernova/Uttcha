//
//  SettingsViewModel.swift
//  Uttcha
//
//  Created by KHJ on 7/12/24.
//

import Foundation
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @AppStorage(UserDefaultsKeys.isNotificationOn) var isNotificationOn = false
    @AppStorage(UserDefaultsKeys.isShowingNotificationOptionsSheet) var isShowingNotificationOptionsSheet = false
    @AppStorage(UserDefaultsKeys.selectedTimeOption) var selectedTimeOption = NotificationTimeOption.day

    @Published var isShowNotificationAuthorizationSettingAlert = false
}

enum NotificationTimeOption: String, CaseIterable {
    case day = "하루"
    case morning = "오전"
    case afternoon = "오후"
    case night = "저녁"
}

struct UserDefaultsKeys {
    static let isNotificationOn = "isNotificationOn"
    static let isShowingNotificationOptionsSheet = "isShowingNotificationOptionsSheet"
    static let selectedTimeOption = "selectedTimeOption"
    static let firstLaunchDate = "firstLaunchDate"
}
