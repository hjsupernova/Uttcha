//
//  NotificationManager.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/07.
//

import UserNotifications

// MARK: - 이거 클래스? struct? 
struct NotificaitonManager {
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
    static func scheduleNotification(notificationTimeString: String) {
        guard let date = DateHelper.dateFormatter.date(from: notificationTimeString) else {
            return
        }

        let content = UNMutableNotificationContent()
        let hour = Int(notificationTimeString.split(separator: ":").first!)!

        switch hour {
        case 8..<12:
            content.title = "하루를 웃으면서 시작해봐요!"
        case 12..<18:
            content.title = "웃을 때 가장 아름다운 나!"
        case 18..<22:
            content.title = "고생한 나! 웃을 자격 있어요!"
        default:
            content.title = "고생한 나! 웃을 자격 있어요!"
        }

        content.body = "Tkae a few minutes to write donw your htoughts and feeligns"
        content.sound = .default

        let dateComponets = Calendar.current.dateComponents([.hour,.minute], from: date)
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
}
