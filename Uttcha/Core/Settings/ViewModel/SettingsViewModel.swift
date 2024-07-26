//
//  SettingsViewModel.swift
//  Uttcha
//
//  Created by KHJ on 7/12/24.
//

import Foundation
import SwiftUI

enum SettingsViewModelAction {
    case dismissOptionSheetWithoutTurningOn
    case scheduleNotifications
    case onOptionSheetAppear
}

final class SettingsViewModel: ObservableObject {
    @AppStorage(UserDefaultsKeys.isNotificationOn) var isNotificationOn = false {
        didSet {
            handleNotificationToggle()
        }
    }
    @AppStorage(UserDefaultsKeys.isShowingNotificationOptionsSheet) var isShowingNotificationOptionsSheet = false
    @AppStorage(UserDefaultsKeys.selectedTimeOption) var selectedTimeOption = NotificationTimeOption.day

    @Published var isShowingNotificationAuthorizationSettingAlert = false

    // MARK: - Actions
    func perform(action: SettingsViewModelAction) {
        switch action {
        case .dismissOptionSheetWithoutTurningOn:
            turnOffNotificationToggle()
        case .scheduleNotifications:
            schduleNotifications()
        case .onOptionSheetAppear:
            break
        }
    }

    // MARK: - Action Handlers
    private func turnOffNotificationToggle() {
        isNotificationOn = false
    }

    private func schduleNotifications() {
        NotificationManager.scheduleNotifications(notificationTimeOption: selectedTimeOption)
        isNotificationOn = true
    }

    private func requestNotificationAuthorization() {
        NotificationManager.requestNotificationAuthorization { success in
            if !success {
                self.isShowingNotificationAuthorizationSettingAlert = true
            }
        }

    }
    // MARK: - Private instance methods
    private func handleNotificationToggle() {
        if isNotificationOn {
            showNotificationOptions()
        } else {
            resetNotificationSettings()
        }
    }

    private func showNotificationOptions() {
        isShowingNotificationOptionsSheet = true
    }

    private func resetNotificationSettings() {
        selectedTimeOption = .day
        NotificationManager.cancelAllNotifications()
    }

}

enum NotificationTimeOption: String, CaseIterable {
    case day = "하루"
    case morning = "오전"
    case afternoon = "오후"
    case night = "저녁"

    var label: String {
        switch self {
        case .day:
            "하루 (08:00 ~ 22:00)"
        case .morning:
            "오전 (08:00 ~ 12:00)"
        case .afternoon:
            "오후 (12:00 ~ 18:00)"
        case .night:
            "저녁 (18:00 ~ 22:00) "
        }
    }
}

struct UserDefaultsKeys {
    static let isNotificationOn = "isNotificationOn"
    static let isShowingNotificationOptionsSheet = "isShowingNotificationOptionsSheet"
    static let selectedTimeOption = "selectedTimeOption"
    static let firstLaunchDate = "firstLaunchDate"
}
