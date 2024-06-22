//
//  SettingsView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/04.
//

import SwiftUI

enum NotificationTimeOption: String, CaseIterable {
    case day = "하루"
    case morning = "오전"
    case afternoon = "오후"
    case night = "저녁"
}
struct SettingsView: View {
    @AppStorage("isScheduled") var isScheduled = false
    @AppStorage("notificationTimeString") var notificationTimeString = ""
    @State private var selectedTiemOption = NotificationTimeOption.day

    var body: some View {
        List {
            Section {
                Toggle("알림 허용", isOn: $isScheduled)
                    .tint(.indigo)
                    .onChange(of: isScheduled) {
                        handleIsScheduledChange(isScheduled: isScheduled)
                    }
            }

            if isScheduled {
                Section {
                    Picker("시간대", selection: $selectedTiemOption) {
                        ForEach(NotificationTimeOption.allCases, id: \.self) { option in
                            Text(option.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                } header: {
                    Text("시간대")
                }
                .onChange(of: selectedTiemOption) { oldValue, newValue in
                    let randomTime = randomTime(for: selectedTiemOption)
                    notificationTimeString = DateHelper.dateFormatter.string(from: randomTime)
                    handleNotificationTimeChange()
                    print(notificationTimeString)
                }
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension SettingsView {
    private func handleIsScheduledChange(isScheduled: Bool) {
        if isScheduled {
            NotificaitonManager.requestNotificationAuthorization()
            NotificaitonManager.scheduleNotification(notificationTimeString: notificationTimeString)

        } else {
            NotificaitonManager.cancelNotification()
        }
    }

    private func handleNotificationTimeChange() {
        NotificaitonManager.cancelNotification()
        NotificaitonManager.requestNotificationAuthorization()
        NotificaitonManager.scheduleNotification(
            notificationTimeString: notificationTimeString
        )
    }

    private func randomTime(for option: NotificationTimeOption) -> Date {
        let calendar = Calendar.current

        var startHour = 0
        var endHour = 0
        switch option {
        case .day:
            startHour = 8
            endHour = 22
        case .morning:
            startHour = 8
            endHour = 12

        case .afternoon:
            startHour = 12
            endHour = 18

        case .night:
            startHour = 18
            endHour = 22

        }

        let randomHour = Int.random(in: startHour..<endHour)

        let randomMinute = Int.random(in: 0..<60)
        let randomSecond = Int.random(in: 0..<60)

        var dateComponents = DateComponents()
        dateComponents.hour = randomHour
        dateComponents.minute = randomMinute
        dateComponents.second = randomSecond

        return calendar.date(from: dateComponents)!
    }
}

// MARK: - 이것도 extension으로 대체
struct DateHelper {
    static let dateFormatter: DateFormatter =  {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
