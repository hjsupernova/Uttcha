//
//  CameraOverlayView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/06.
//

import SwiftUI

struct CameraOverlayView: View {
    @ObservedObject var cameraViewModel: CameraViewModel
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.black)

                    ProgressView(cameraViewModel.cameraInstructionText, value: cameraViewModel.smileProgress, total: 100)
                        .foregroundStyle(.white)
                        .font(.title2).bold()
                        .padding(.horizontal)
                        .padding(.top)
                }

                Spacer()
                    .frame(height: geo.size.width * 4 / 3)

                ZStack {
                    Rectangle()
                        .fill(Color.black)

                    if cameraViewModel.smileProgress == 100 {
                        Shutter()
                            .padding(.bottom)
                            .onTapGesture {
                                cameraViewModel.perform(action: .takePhoto)
                            }
                    }

                    HStack {
                        Button {
                            cameraViewModel.perform(action: .dismissCamera)
                        } label: {
                            Text("취소")
                                .foregroundStyle(.white)
                                .font(.title2)
                        }

                        Spacer()

                        Menu {
                            Picker("함께 웃기", selection: $cameraViewModel.neededFaceCount) {
                                ForEach(1..<6) {
                                    Text("함께 웃기: \($0) 명").tag($0)
                                }
                            }
                        } label: {
                            Image(systemName: "person.2.fill")
                                .font(.title2)

                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            cameraViewModel.perform(action: .onOverlayViewAppeared)
        }
    }
}

#Preview {
    CameraOverlayView(cameraViewModel: CameraViewModel())
}
