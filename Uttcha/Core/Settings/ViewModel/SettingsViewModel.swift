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
        }
    }

    // MARK: - Action Handlers
    private func turnOffNotificationToggle() {
        isNotificationOn = false
    }

    private func schduleNotifications() {
        NotificationManager.scheduleNotifications(notificationTimeOption: selectedTimeOption)
    }

    // MARK: - Private instance methods
    private func handleNotificationToggle() {
        if isNotificationOn {
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch settings.authorizationStatus {
                    case .notDetermined:
                        self.requestAuthorization()
                    case .denied:
                        self.isShowingNotificationAuthorizationSettingAlert = true
                        self.isNotificationOn = false
                    case .authorized, .provisional:
                        self.showNotificationOptions()
                    default:
                        break
                    }
                }
            }
        } else {
            resetNotificationOptions()
            NotificationManager.cancelAllNotifications()
        }
    }

    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if granted {
                    self.showNotificationOptions()
                } else {
                    self.isShowingNotificationAuthorizationSettingAlert = true
                    self.isNotificationOn = false
                }
            }
        }
    }

    private func showNotificationOptions() {
        isShowingNotificationOptionsSheet = true
    }

    private func resetNotificationOptions() {
        selectedTimeOption = .day
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
            "저녁 (18:00 ~ 22:00)"
        }
    }

    var timeRange: (start: Int, end: Int) {
        switch self {
        case .day:
            (8, 22)
        case .morning:
            (8, 12)
        case .afternoon:
            (12, 18)
        case .night:
            (18, 22)
        }
    }
}

struct UserDefaultsKeys {
    static let isNotificationOn = "isNotificationOn"
    static let isShowingNotificationOptionsSheet = "isShowingNotificationOptionsSheet"
    static let selectedTimeOption = "selectedTimeOption"
    static let firstLaunchDate = "firstLaunchDate"
    static let hasTakenFirstPhoto = "hasTakenFirstPhoto"
}
