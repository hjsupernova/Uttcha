//
//  SplineTest.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/07.
//

import SwiftUI

struct Shutter: View {

    var body: some View {
        VStack {
            Spacer()

            ZStack {
                Circle()
                    .frame(height: 100)

                Circle()
                    .stroke(lineWidth: 3.0)
                    .foregroundStyle(.black)
                    .frame(height: 80)

            }
        }
        .padding(.bottom)
    }
}

#Preview {
        Shutter()
}
