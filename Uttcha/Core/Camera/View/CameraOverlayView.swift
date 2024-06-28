//
//  CameraOverlayView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/06.
//

import SwiftUI

struct CameraOverlayView: View {
    @ObservedObject var model: CameraViewModel
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.black)

                    ProgressView(model.smileInformation, value: model.smileProgress, total: 100)
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

                    if model.smileProgress == 100 {
                        Shutter()
                            .onTapGesture {
                                model.perform(action: .takePhoto)
                            }
                            .padding(.bottom)
                    }

                    HStack {
                        Button {
                            model.perform(action: .dismissCamera)
                        } label: {
                            Text("취소")
                                .foregroundStyle(.white)
                                .font(.title2)
                        }

                        Spacer()

                    }
                    .padding(.horizontal)
                }
            }

        }
    }
}

#Preview {
    CameraOverlayView(model: CameraViewModel())
}
