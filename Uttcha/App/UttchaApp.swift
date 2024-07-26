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
    @AppStorage(UserDefaultsKeys.isNotificationOn) var isNotificationOn = false
    @AppStorage(UserDefaultsKeys.selectedTimeOption) var selectedTimeOption = NotificationTimeOption.day
    @Environment(\.scenePhase) var scenePhase

    private var coreDataStack = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            UttchaTapView()
                .preferredColorScheme(.dark)
                .tint(.white)
                .environment(\.managedObjectContext, coreDataStack.persistentContainer.viewContext)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    coreDataStack.save()
                }
                .onAppear {
                    if UserDefaults.standard.object(forKey: UserDefaultsKeys.firstLaunchDate) == nil {
                        UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.firstLaunchDate)
                    }
                }
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .active && isNotificationOn {
                NotificationManager.scheduleNotificationsIfNeeded(notificationTimeOption: selectedTimeOption)
            }
        }
    }
}

/// A global logger for the app.
let notificationLogger = Logger(subsystem: "com.hjdrw.Uttcha.notification", category: "notification")
