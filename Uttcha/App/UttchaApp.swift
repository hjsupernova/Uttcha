//
//  UttchaApp.swift
//  Uttcha
//
//  Created by KHJ on 2024/04/06.
//

import SwiftUI

@main
struct UttchaApp: App {
    @StateObject private var coreDataStack = CoreDataStack.shared
    @AppStorage("isNotificationOn") var isNotificationOn = false
    @AppStorage("selectedTimeOption") var selectedTimeOption = NotificationTimeOption.day

    var body: some Scene {
        WindowGroup {
            UttchaTapView()
                .environment(\.managedObjectContext, coreDataStack.persistentContainer.viewContext)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    coreDataStack.save()
                }
                .onAppear {
                    if isNotificationOn {
                        NotificationManager.scheduleNotificationsIfNeeded(notificationTimeOption: selectedTimeOption)
                    }
                }
                .preferredColorScheme(.dark)
                .tint(.white)
        }
    }
}
