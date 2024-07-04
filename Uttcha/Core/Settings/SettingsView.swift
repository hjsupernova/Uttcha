//
//  SettingsView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/04.
//

import SwiftUI

enum NotificationTimeOption: String, CaseIterable {
    case day = "하루"
    case morning = "오전"
    case afternoon = "오후"
    case night = "저녁"
}

struct SettingsView: View {
    @AppStorage("isNotificationOn") var isNotificationOn = false
    @AppStorage("isShowingNotificationOptionsSheet") var isShowingNotificationOptionsSheet = false
    @AppStorage("selectedTimeOption") var selectedTimeOption = NotificationTimeOption.day

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                NotificationSettingsSection(
                    isNotificationOn: $isNotificationOn,
                    isShowingNotificationOptionsSheet: $isShowingNotificationOptionsSheet,
                    selectedTimeOption: $selectedTimeOption
                )

                AppInfoSection()
            }
        }
        .padding()
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingNotificationOptionsSheet) {
            NotificaitonOptionsSheet(selectedTimeOption: $selectedTimeOption, isNotificationOn: $isNotificationOn)
                .presentationDetents([.medium])
        }
    }
}

struct NotificationSettingsSection: View {
    @Binding var isNotificationOn: Bool
    @Binding var isShowingNotificationOptionsSheet: Bool
    @Binding var selectedTimeOption: NotificationTimeOption

    var body: some View {
        Text("설정")

        GroupBox {
            Toggle("알림 \(isNotificationOn ? "ON" : "OFF")", isOn: $isNotificationOn)
                .onChange(of: isNotificationOn) {
                    if isNotificationOn {
                        isShowingNotificationOptionsSheet = true
                    } else {
                        selectedTimeOption = .day
                        NotificationManager.cancelAllNotifications()
                    }
                }
                .tint(.green)

            HStack {
                if isNotificationOn {
                    Text("\(selectedTimeOption.rawValue)중 알림을 무작위로 보내드릴게요!")
                } else {
                    Text("알림 시간대를 설정할 수 있어요")
                }

                Spacer()
            }
        }
    }
}

struct NotificaitonOptionsSheet: View {
    @Binding var selectedTimeOption: NotificationTimeOption
    @Binding var isNotificationOn: Bool
    @State private var isShowNotificationAuthorizationSettingAlert = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Text("알림 설정하기")
                    .font(.title).bold()

                Spacer()

                Button {
                    dismiss()
                    isNotificationOn = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.title)
                }
            }

            Spacer()

            Picker("", selection: $selectedTimeOption) {
                ForEach(NotificationTimeOption.allCases, id: \.self) { option in
                    switch option {
                    case .day:
                        Text(option.rawValue + " (08:00 ~ 22:00)")
                    case .morning:
                        Text(option.rawValue + " (08:00 ~ 12:00)")
                    case .afternoon:
                        Text(option.rawValue + " (12:00 ~ 18:00)")
                    case .night:
                        Text(option.rawValue + " (18:00 ~ 22:00)")
                    }
                }
            }
            .labelsHidden()
            .pickerStyle(.wheel)

            Spacer()

            Button {
                scheduleNotificaiton()
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
        .onAppear {
            print("Onappear")

            NotificationManager.requestNotificationAuthorization { success in
                print(success)
                if !success {
                    showNotificationAuthorizationSettingAlert()
                }
            }
        }
        .alert("Uttcha", isPresented: $isShowNotificationAuthorizationSettingAlert) {
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

    private func scheduleNotificaiton() {
        NotificationManager.scheduleNotifications(notificationTimeOption: selectedTimeOption)
        isNotificationOn = true
    }

    private func showNotificationAuthorizationSettingAlert() {
        isShowNotificationAuthorizationSettingAlert = true
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
