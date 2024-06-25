//
//  NotificationManager.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/07.
//

import UserNotifications

// MARK: - 이거 클래스? struct? 
struct NotificationManager {
    static func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                print("sucesss")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    // 유저 선택 시간에 데일리 로컬 실행
    static func scheduleNotification(notificationTimeOption: NotificationTimeOption) {
        let randomDate = randomTime(for: notificationTimeOption)
        let content = UNMutableNotificationContent()
        let hour = Calendar.current.component(.hour, from: randomDate)
        
        switch hour {
        case 8..<12:
            content.title = "하루를 웃으면서 시작해봐요!"
            content.body = "하던 일을 잠깐 멈추고 웃어보세요!"
        case 12..<18:
            content.title = "웃을 때 가장 아름다운 나!"
            content.body = "하던 일을 잠깐 멈추고 웃어보세요!"
        case 18..<22:
            content.title = "고생한 나! 웃을 자격 있어요!"
            content.body = "하던 일을 잠깐 멈추고 웃어보세요!"
        default:
            content.title = "고생한 나! 웃을 자격 있어요!"
            content.body = "하던 일을 잠깐 멈추고 웃어보세요!"
        }
        content.sound = .default

        let dateComponets = Calendar.current.dateComponents([.hour,.minute], from: randomDate)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponets,
            repeats: true
        )

        // We need the identifier "journalReminder" so that we can cancel it later if needed
        let request = UNNotificationRequest(
            identifier: "journalReminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            requests.forEach {
                print($0.content.title)
            }
        }
    }

    static func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["journalReminder"])
    }

    static func randomTime(for option: NotificationTimeOption) -> Date {
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
