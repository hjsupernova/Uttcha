//
//  CameraScreenView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/06.
//

import SwiftUI

struct CameraScreenView: View {
    @ObservedObject var cameraViewModel: CameraViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ZStack {
                    CameraView(cameraViewModel: cameraViewModel)

                    LottieSmile()

                    CameraOverlayView(cameraViewModel: cameraViewModel)
                }
                .navigationDestination(item: $cameraViewModel.facePhoto) { takenImage in
                    PhotoPreviewView(cameraViewModel: cameraViewModel, image: takenImage)
                }
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    CameraScreenView(cameraViewModel: CameraViewModel())
}
