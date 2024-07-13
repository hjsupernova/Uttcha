//
//  PhotoPreviewView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/06.
//

import SwiftUI

struct PhotoPreviewView: View {
    @ObservedObject var cameraViewModel: CameraViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel

    let photo: UIImage

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Spacer()

            Image(uiImage: photo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                            cameraViewModel.perform(action: .savePhoto(photo))
                            homeViewModel.perform(action: .saveButtonTapped)
                        } label: {
                            Text("저장 하기")
                        }
                    }
                }

            Spacer()
        }
        .ignoresSafeArea()
        .background(.black)
    }
}
