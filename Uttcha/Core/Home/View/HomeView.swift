//
//  UICalendar.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/06.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var model = CameraViewModel()
    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                SmileCalendar(
                    homeViewModel: homeViewModel,
                    calendar: .autoupdatingCurrent,
                    monthsLayout: .horizontal,
                    isShowingCamera: $model.isShowingCameraView
                )
                .padding()

                HStack {
                    FaceCounter(model: model)

                    Spacer()

                    CameraButton(model: model, homeViewModel: homeViewModel)
                }
                .padding()
            }
            .navigationTitle("오늘도 웃차 🤙🏻")
            .toolbar {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "bell.fill")
                }
            }
        }
        .fullScreenCover(isPresented: $model.isShowingCameraView) {
            CameraScreenView(model: model)
        }
        .environmentObject(homeViewModel)
    }
}

struct FaceCounter: View {
    @ObservedObject var model: CameraViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemGray6))
                .frame(width: 150, height: 100)

            VStack {
                Text("함께 웃기: \(model.neededFaceCount) 명")
                    .fontWeight(.bold)

                Stepper("") {
                    model.perform(action: .incrementNeededFaceCount)
                } onDecrement: {
                    model.perform(action: .decrementNeededFaceCount)
                }
                .labelsHidden()
            }
        }
    }
}

struct CameraButton: View {
    @ObservedObject var model: CameraViewModel
    @ObservedObject var homeViewModel: HomeViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemGray6))
                .frame(width: 150, height: 100)

            VStack {
                Button {
                    model.perform(action: .showCamera)
                } label: {
                    VStack {
                        Text(homeViewModel.isCameraButtonDisabled ? "내일 봐요!" : "웃어 봐요!")
                            .fontWeight(.bold)

                        Text(homeViewModel.isCameraButtonDisabled ? "😘" : "🥲")
                            .font(.largeTitle)
                    }
                }
                .disabled(homeViewModel.isCameraButtonDisabled)
            }
        }
    }
}

#Preview {
    UttchaTapView()
}
