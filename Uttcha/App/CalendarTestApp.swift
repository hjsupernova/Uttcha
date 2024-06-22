//
//  CalendarTestApp.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/06.
//

import SwiftUI

@main
struct CalendarTestApp: App {
    @StateObject private var coreDataStack = CoreDataStack.shared
    var body: some Scene {
        WindowGroup {
            UttchaTapView()
                .environment(\.managedObjectContext, coreDataStack.persistentContainer.viewContext)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    coreDataStack.save()
                }
        }
    }
}
