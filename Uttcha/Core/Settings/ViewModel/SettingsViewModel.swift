//
//  SettingsViewModel.swift
//  Uttcha
//
//  Created by KHJ on 7/12/24.
//

import Foundation
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @AppStorage("isNotificationOn") var isNotificationOn = false
    @AppStorage("isShowingNotificationOptionsSheet") var isShowingNotificationOptionsSheet = false
    @AppStorage("selectedTimeOption") var selectedTimeOption = NotificationTimeOption.day

    @Published var isShowNotificationAuthorizationSettingAlert = false
}

enum NotificationTimeOption: String, CaseIterable {
    case day = "하루"
    case morning = "오전"
    case afternoon = "오후"
    case night = "저녁"
}
