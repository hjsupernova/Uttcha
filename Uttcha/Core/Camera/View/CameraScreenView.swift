//
//  CameraScreenView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/06.
//

import SwiftUI

struct CameraScreenView: View {
    @ObservedObject var model: CameraViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ZStack {
                    CameraView(model: model)

                    DebugText(model: model)

                    LottieSmile()

                    CameraOverlayView(model: model)
                }
                .navigationDestination(item: $model.facePhoto) { takenImage in
                    PhotoPreviewView(model: model, image: takenImage)
                }
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    CameraScreenView(model: CameraViewModel())
}
