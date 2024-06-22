//
//  UICalendar.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/06.
//

import SwiftUI

import SwiftUIIntrospect

struct HomeView: View {
    @StateObject private var model = CameraViewModel()
    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: 0xF4EEF4)
                    .ignoresSafeArea()

                ScrollView {
                    SmileCalendar(
                        calendar: .autoupdatingCurrent,
                        monthsLayout: .horizontal,
                        isShowingCamera: $model.isShowingCameraView
                    )
                    .background(
                        .pink,
                        in: RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        )
                    )
                    .padding()

                    VStack {
                        Stepper("같이 웃을 사람 \(model.neededFaceCount) 명") {
                            model.perform(action: .faceCountIncrement)
                        } onDecrement: {
                            model.perform(action: .faceCountDecrement)
                        }
                        .padding(.horizontal)
                    }
                    .background(.white)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 8,
                            style: .continuous
                        )
                    )
                    .padding()

                }
                VStack {
                    Spacer()

                    HStack {
                        Spacer()

                        Button {
                            model.perform(action: .showCamera)
                        } label: {
                            ZStack {
                                Circle()
                                    .foregroundStyle(.blue)
                                    .frame(height: 50)

                                Image(systemName: "smiley")
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("오늘도 ☺️")
            .navigationBarLargeTitleItems(trailing: SettingButton())
        }
        .introspect(.navigationStack, on: .iOS(.v16, .v17)) {
            let color = UIColor(red: 244/255, green: 238/255, blue: 244/255, alpha: 1.0)

            $0.navigationBar.backgroundColor = color
            print(type(of: $0)) // UINavigationController
        }
        .fullScreenCover(isPresented: $model.isShowingCameraView) {
            CameraScreenView(model: model)
        }
    }
}

struct SettingButton: View {
    var body: some View {
        NavigationLink {
            SettingsView()
        } label: {
            Image(systemName: "bell.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.red)
                .frame(width: 36, height: 36)
                .padding([.trailing], 20)
                .padding([.top], 5)
        }

    }
}

#Preview {
    HomeView()
}
