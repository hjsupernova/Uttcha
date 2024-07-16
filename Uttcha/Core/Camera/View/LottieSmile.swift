//
//  LottieAnimationView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/15.
//

import SwiftUI
import Lottie

struct LottieSmile: View {
    @State private var isFinished = false

    var body: some View {
        LottieView(animation: .named("smile"))
            .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce)))
            .animationSpeed(0.8)
            .animationDidFinish { completed in
                withAnimation {
                    isFinished = true
                }
            }
            .opacity(isFinished ? 0 : 1)
    }
}

#Preview {
    LottieSmile()
}
