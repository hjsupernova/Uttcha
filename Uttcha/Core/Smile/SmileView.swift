//
//  SmileView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/10.
//

import SwiftUI

import SwiftUIIntrospect

struct SmileView: View {
    var body: some View {
        NavigationStack {
//            Color(hex: 0xFFFFFA )
            ZStack {
                Color.yellow
                
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                    .navigationTitle("asdf")
            }
        }
        .introspect(.navigationStack, on: .iOS(.v16, .v17)) {
            $0.navigationBar.backgroundColor = .cyan
            print(type(of: $0)) // UINavigationController
        }
    }
}

#Preview {
    SmileView()
}
