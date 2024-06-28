//
//  NotificationManager.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/07.
//

import UserNotifications

// MARK: - 이거 클래스? struct? 
struct NotificationManager {
    static let smileIdentifier = "SmileIdentifier"

    static func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                print("Notification authorization granted.")
            } else if let error = error {
                print("Notification authorization failed: \(error.localizedDescription)")
            }
        }
    }

    /// Schedule notifications for the next 64 days if less than 30 notifications are scheduled
    static func scheduleNotificationsIfNeeded(notificationTimeOption: NotificationTimeOption) {
        for dayOffset in 1..<64 {
            let randomTime = generateRandomTime(for: notificationTimeOption, dayOffset: dayOffset)
            scheduleNotification(for: randomTime)
        }
    }

    /// Schedule notifications for the next 64 days
    static func scheduleNotifications(notificationTimeOption: NotificationTimeOption) {
        for dayOffset in 0..<64 {
            let randomMoment = generateRandomTime(for: notificationTimeOption, dayOffset: dayOffset)
            scheduleNotification(for: randomMoment)
        }

    }

    /// Schedule a notification at the specified date and time
    static func scheduleNotification(for dateComponents: DateComponents) {
        let content = UNMutableNotificationContent()
        let hour = dateComponents.hour ?? 0

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

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = "\(smileIdentifier)_\(dateComponents.month!)_\(dateComponents.day!)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled at \(dateComponents)")
            }
        }
    }

    /// Cancel all scheduled notifications
    static func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    static func cancelNotificationFor(_ date: Date) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger,
                   let triggerDate = Calendar.current.date(from: calendarTrigger.dateComponents) {

                    if Calendar.current.isDate(triggerDate, inSameDayAs: date) {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
                    }
                }
            }
        }
    }

//    static func printAllNotifications() {
//        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
//            for request in requests {
//                print(request.identifier)
//            }
//        }
//    }

    static func generateRandomTime(for option: NotificationTimeOption, dayOffset: Int) -> DateComponents {
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

        if let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: Date()) {
            dateComponents.year = calendar.component(.year, from: futureDate)
            dateComponents.month = calendar.component(.month, from: futureDate)
            dateComponents.day = calendar.component(.day, from: futureDate)
        }

        return dateComponents
    }
}
