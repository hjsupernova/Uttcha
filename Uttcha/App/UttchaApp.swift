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
    @StateObject var spotifyController = SpotifyController()
    @AppStorage(UserDefaultsKeys.isNotificationOn) var isNotificationOn = false
    @AppStorage(UserDefaultsKeys.selectedTimeOption) var selectedTimeOption = NotificationTimeOption.day

    private var coreDataStack = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            UttchaTapView()
                .preferredColorScheme(.dark)
                .tint(.white)
                .environment(\.managedObjectContext, coreDataStack.persistentContainer.viewContext)
                .environmentObject(spotifyController)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    coreDataStack.save()
                }
                .onOpenURL { url in
                    spotifyController.setAccessToken(from: url)
                }
                .onAppear {
                    if isNotificationOn {
                        NotificationManager.scheduleNotificationsIfNeeded(notificationTimeOption: selectedTimeOption)
                    }

                    if UserDefaults.standard.object(forKey: UserDefaultsKeys.firstLaunchDate) == nil {
                        UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.firstLaunchDate)
                    }

                }
        }
    }
}

/// A global logger for the app.
let notificationLogger = Logger(subsystem: "com.hjdrw.Uttcha.notification", category: "notification")
