//
//  UttchaApp.swift
//  Uttcha
//
//  Created by KHJ on 2024/04/06.
//

import os
import SwiftUI

@main
struct UttchaApp: App {
    private var coreDataStack = CoreDataStack.shared
    @AppStorage(UserDefaultsKeys.isNotificationOn) var isNotificationOn = false
    @AppStorage(UserDefaultsKeys.selectedTimeOption) var selectedTimeOption = NotificationTimeOption.day

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

                    if UserDefaults.standard.object(forKey: UserDefaultsKeys.firstLaunchDate) == nil {
                        UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.firstLaunchDate)
                    }
                }
                .preferredColorScheme(.dark)
                .tint(.white)
        }
    }
}

/// A global logger for the app.
let notificationLogger = Logger(subsystem: "com.hjdrw.Uttcha.notification", category: "notification")
