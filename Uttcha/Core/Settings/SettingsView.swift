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
    @AppStorage("isShowingNotificaitonOptionsSheet") var isShowingNotificaitonOptionsSheet = false
    @AppStorage("selectedTimeOption") var selectedTimeOption = NotificationTimeOption.day

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("설정")

                GroupBox {
                    Toggle("알림 \(isNotificationOn ? "ON" : "OFF")", isOn: $isNotificationOn)
                        .onChange(of: isNotificationOn) {
                            if isNotificationOn {
                                isShowingNotificaitonOptionsSheet = true
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

            VStack(alignment: .leading) {
                Text("앱 정보")

                GroupBox {
                    HStack {
                        Text("웃차에 대해서")

                        Spacer()
                    }
                }
            }
        }
        .padding()
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingNotificaitonOptionsSheet) {
            NotificaitonOptionsSheet(selectedTiemOption: $selectedTimeOption, isNotificationOn: $isNotificationOn)
                .presentationDetents([.medium])
        }
    }
}

struct NotificaitonOptionsSheet: View {
    @Binding var selectedTiemOption: NotificationTimeOption
    @Binding var isNotificationOn: Bool

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

            Picker("", selection: $selectedTiemOption) {
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
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .interactiveDismissDisabled()
        .onAppear {
            NotificationManager.requestNotificationAuthorization()
        }
    }

    private func scheduleNotificaiton() {
        NotificationManager.scheduleNotifications(notificationTimeOption: selectedTiemOption)
        isNotificationOn = true
    }
}

// MARK: - 이것도 extension으로 대체
struct DateHelper {
    static let dateFormatter: DateFormatter =  {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
