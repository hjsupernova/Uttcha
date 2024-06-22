//
//  UttchaTapView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/10.
//

import SwiftUI

enum Views {
    case calendar, smile
}

struct UttchaTapView: View {
    @State private var selectedTap: Views = .calendar

    var body: some View {
        TabView(selection: $selectedTap) {
            HomeView()
                .tabItem {
                    Label("캘린더", systemImage: "calendar")
                }
                .tag(Views.calendar)

            SmileView()
                .tabItem {
                    Label("스마일", systemImage: "smiley")
                }
                .tag(Views.smile)
        }
    }
}

#Preview {
    UttchaTapView()
}
