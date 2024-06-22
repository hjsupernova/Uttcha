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
                    .foregroundStyle(.white)
                    .frame(height: 100)

                Circle()
                    .stroke(lineWidth: 3.0)
                    .frame(height: 75)

            }
        }
        .padding(.bottom)
    }
}

#Preview {
    ZStack {
        Color.red

        Shutter()
    }

}
