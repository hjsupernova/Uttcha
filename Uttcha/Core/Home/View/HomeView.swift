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
                Color.black
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

                    HStack {

                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(uiColor: .systemGray6))
                                .frame(width: 150, height: 100)

                            VStack {
                                Text("함께 웃기: \(model.neededFaceCount) 명")
                                    .fontWeight(.bold)

                                Stepper("") {
                                    model.perform(action: .faceCountIncrement)
                                } onDecrement: {
                                    model.perform(action: .faceCountDecrement)
                                }
                                .labelsHidden()
                            }
                        }

                        Spacer()

                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(uiColor: .systemGray6))
                                .frame(width: 150, height: 100)


                            Button {
                                model.perform(action: .showCamera)
                            } label: {
                                ZStack {
                                    Circle()
                                        .frame(height: 50)
                                        .foregroundStyle(.white)

                                    Text("😁")
                                }
                            }
                        }
                    }
                    .padding()
                }
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
    }
}

extension View {
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
        return self
    }
}

#Preview {
    UttchaTapView()
}
