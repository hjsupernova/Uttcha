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

                ReviewSection(settingsViewModel: settingsViewModel)
            }
        }
        .padding()
        .navigationTitle("Settings")
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
            Text("Record")
                .font(.callout)

            GroupBox {
                VStack {
                    Text("Days you smiled with Uttcha 😍")

                    Text("\(settingsViewModel.photoCount) day(s)")
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
            Text("Settings")
                .font(.callout)

            GroupBox {
                Toggle("Notifications \(settingsViewModel.isNotificationOn ? "ON" : "OFF")", isOn: $settingsViewModel.isNotificationOn)
                    .tint(.green)

                HStack {
                    Text(
                        settingsViewModel.isNotificationOn
                        ? "We'll send notifications randomly during \(settingsViewModel.selectedTimeOption.localizedTimeOption)"
                        : "You can set a notification time"
                    )
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $settingsViewModel.isShowingNotificationOptionsSheet) {
            NotificaitonOptionsSheet(settingsViewModel: settingsViewModel)
                .presentationDetents([.medium])
        }
        .alert("Uttcha", isPresented: $settingsViewModel.isShowingNotificationAuthorizationSettingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Go to Settings") {
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!,
                    options: [:],
                    completionHandler: nil)
            }
        } message: {
            Text("The app doesn't have notification permission. Please update your settings.")
        }
    }
}

struct NotificaitonOptionsSheet: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Text("Set Notifications")
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
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .font(.title2)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .interactiveDismissDisabled()
    }
}

struct ReviewSection: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("About")
                .font(.callout)

            GroupBox {
                VStack {
                    if let reviewURL = settingsViewModel.reviewURL {
                        Link(destination: reviewURL) {
                            HStack {
                                Label("Rate Uttcha", systemImage: "star")

                                Spacer()
                            }
                        }
                    }
                }.frame(maxWidth: .infinity)
            }
        }
    }
}

//struct AppInfoSection: View {
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text("앱 정보")
//                .font(.callout)
//
//            GroupBox {
//                HStack {
//                    Text("웃차에 대해서")
//
//                    Spacer()
//                }
//            }
//        }
//    }
//}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
