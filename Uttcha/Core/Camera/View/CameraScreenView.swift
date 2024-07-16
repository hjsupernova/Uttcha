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
                .ignoresSafeArea()
                .navigationDestination(item: $cameraViewModel.facePhoto) { facePhoto in
                    PhotoPreviewView(cameraViewModel: cameraViewModel, photo: facePhoto)
                }
            }
        }
    }
}

#Preview {
    CameraScreenView(cameraViewModel: CameraViewModel())
}
