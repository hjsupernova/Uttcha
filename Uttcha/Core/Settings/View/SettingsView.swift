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
            VStack(alignment: .leading) {
                NotificationSettingsSection(settingsViewModel: settingsViewModel)

                AppInfoSection()
            }
        }
        .padding()
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationSettingsSection: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        Text("설정")

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
        Text("앱 정보")

        GroupBox {
            HStack {
                Text("웃차에 대해서")

                Spacer()
            }
        }
    }
}
#Preview {
    NavigationStack {
        SettingsView()
    }
}
