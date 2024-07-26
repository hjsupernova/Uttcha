//
//  NotificationManager.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/07.
//

import UserNotifications

struct NotificationManager {
    static let smileIdentifier = "SmileIdentifier"

    /// Schedule notifications for the next 64 days if less than 30 notifications are scheduled
    static func scheduleNotificationsIfNeeded(notificationTimeOption: NotificationTimeOption) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let pendingCount = requests.count
            let currentDate = Date()
            let newNotificationsNeeded = max(0, 64 - pendingCount)
            notificationLogger.debug("Notification Pending Count: \(pendingCount)")

            guard newNotificationsNeeded != 0 else { return }

            let lastScheduledDate = requests.compactMap { $0.trigger as? UNCalendarNotificationTrigger }
                .compactMap { $0.nextTriggerDate() }
                .max() ?? currentDate

            for dayOffset in 1...newNotificationsNeeded {
                guard let notificationDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: lastScheduledDate) else { return }
                let randomTime = generateRandomTime(for: notificationTimeOption, date: notificationDate)
                scheduleNotification(for: randomTime)
            }
        }
    }

    /// Schedule notifications for the next 64 days
    static func scheduleNotifications(notificationTimeOption: NotificationTimeOption) {
        for dayOffset in 0..<64 {
            guard let notificationDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) else { return }
            let randomTime = generateRandomTime(for: notificationTimeOption, date: notificationDate)
            scheduleNotification(for: randomTime)
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
                notificationLogger.error("Error scheduling notification: \(error.localizedDescription)")
            } else {
                notificationLogger.debug("Notification scheduled at \(dateComponents)")
            }
        }
    }

    static func requestNotificationAuthorizationAndSchedule(for option: NotificationTimeOption) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) { granted, _ in
            if granted {
                scheduleNotifications(notificationTimeOption: option)
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isNotificationOn)
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
    
    private static func generateRandomTime(for option: NotificationTimeOption, date: Date) -> DateComponents {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        let (startHour, endHour) = option.timeRange
        let randomHour = Int.random(in: startHour..<endHour)
        let randomMinute = Int.random(in: 0..<60)
        components.hour = randomHour
        components.minute = randomMinute

        return components
    }
}
