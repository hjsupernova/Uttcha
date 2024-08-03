//
//  SettingsView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/04.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SmileRecordSection(settingsViewModel: settingsViewModel)

                NotificationSettingsSection(settingsViewModel: settingsViewModel)

//                AppInfoSection()
            }
        }
        .padding()
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            settingsViewModel.perform(action: .onAppear)
        }
    }
}

struct SmileRecordSection: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("기록")
                .font(.callout)

            GroupBox {
                VStack {
                    Text("웃차와 함께 웃은 날 😍")

                    Text("\(settingsViewModel.photoCount)일")
                        .font(.title3)
                        .bold()

                }.frame(maxWidth: .infinity)
            }
        }
    }
}

struct NotificationSettingsSection: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("설정")
                .font(.callout)

            GroupBox {
                Toggle("알림 \(settingsViewModel.isNotificationOn ? "ON" : "OFF")", isOn: $settingsViewModel.isNotificationOn)
                    .tint(.green)

                HStack {
                    Text(
                        settingsViewModel.isNotificationOn ? "\(settingsViewModel.selectedTimeOption.rawValue)중 알림을 무작위로 보내드릴게요!" : "알림 시간대를 설정할 수 있어요"
                    )
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $settingsViewModel.isShowingNotificationOptionsSheet) {
            NotificaitonOptionsSheet(settingsViewModel: settingsViewModel)
                .presentationDetents([.medium])
        }
        .alert("웃자", isPresented: $settingsViewModel.isShowingNotificationAuthorizationSettingAlert) {
            Button("취소", role: .cancel) { }
            Button("설정으로 이동") {
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!,
                    options: [:],
                    completionHandler: nil)
            }
        } message: {
            Text("앱에 알림 권한이 없습니다. 설정을 변경해주세요.")
        }
    }
}

struct NotificaitonOptionsSheet: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Text("알림 설정하기")
                    .font(.title).bold()

                Spacer()

                Button {
                    dismiss()
                    settingsViewModel.perform(action: .dismissOptionSheetWithoutTurningOn)
                } label: {
                    Image(systemName: "xmark")
                        .font(.title)
                }
            }

            Spacer()

            Picker("", selection: $settingsViewModel.selectedTimeOption) {
                ForEach(NotificationTimeOption.allCases, id: \.self) { option in
                    Text(option.label)
                }
            }
            .labelsHidden()
            .pickerStyle(.wheel)

            Spacer()

            Button {
                settingsViewModel.perform(action: .scheduleNotifications)
                dismiss()
            } label: {
                Text("저장")
                    .frame(maxWidth: .infinity)
                    .font(.title2)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .interactiveDismissDisabled()
    }
}

struct AppInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("앱 정보")
                .font(.callout)

            GroupBox {
                HStack {
                    Text("웃차에 대해서")

                    Spacer()
                }
            }
        }
    }
}
#Preview {
    NavigationStack {
        SettingsView()
    }
}
