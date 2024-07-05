//
//  SmileCalendar.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/11.
//

import CoreData
import SwiftUI
import UIKit

import HorizonCalendar
import Kingfisher

struct SmileCalendar: View {
    @ObservedObject private var homeViewModel: HomeViewModel
    @StateObject private var calendarViewProxy = CalendarViewProxy()

    private let calendar: Calendar
    private let monthsLayout: MonthsLayout
    private let visibleDateRange: ClosedRange<Date>
    private let monthDateFormatter: DateFormatter
    private let dayNames = ["일", "월", "화", "수", "목", "금", "토"]

    @State private var selectedImage: Photo?
    @Binding var isShowingCamera: Bool

    init(homeViewModel: HomeViewModel, calendar: Calendar, monthsLayout: MonthsLayout, isShowingCamera: Binding<Bool>) {
        self.homeViewModel = homeViewModel
        self.calendar = calendar
        self.monthsLayout = monthsLayout

        let firstLaunchDate = UserDefaults.standard.object(forKey: "FirstLaunchDate") as? Date ?? Date()
        let startDate = calendar.date(byAdding: .year, value: -2, to: firstLaunchDate)!
        let endDate = Date()
        visibleDateRange = startDate...endDate

        monthDateFormatter = DateFormatter()
        monthDateFormatter.calendar = calendar
        monthDateFormatter.locale = Locale(identifier: "ko_KR")
        monthDateFormatter.dateFormat = "yyyy년 M월"
        _isShowingCamera = isShowingCamera
    }

    var body: some View {
        // TODO: dataEpendency에 사진을 넣어야하나..? 확인 
        CalendarViewRepresentable(
            calendar: calendar,
            visibleDateRange: visibleDateRange,
            monthsLayout: monthsLayout,
            dataDependency: homeViewModel.photos,
            proxy: calendarViewProxy
        )
        .backgroundColor(.systemGray6)

        .horizontalDayMargin(0)
        .verticalDayMargin(12)

        .monthHeaders { month in
            let monthHeaderText = monthDateFormatter.string(from: calendar.date(from: month.components)!)
            Button {
                homeViewModel.perform(action: .showMonthsSheet)
            } label: {
                HStack {
                    Text(monthHeaderText)
                        .font(.title2).bold()

                    Image(systemName: "arrowtriangle.down.fill")
                        .foregroundStyle(.gray)

                }
                .padding()
            }
        }
        .dayOfWeekHeaders { month, weekdayIndex in
            Text(dayNames[weekdayIndex]).bold()
        }
        .days { day in
            Text("\(day.day)")
                .bold()
        }
        .dayBackgrounds { day in
            let calendarDate = calendar.date(from: day.components)!
            let image = homeViewModel.photos.filter {
                calendar.isDate($0.date!, inSameDayAs: calendarDate)
            }.first

            if let image = image {
                KFImage
                    .data(image.blob!, cacheKey: image.date!.description)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .onDaySelection { day in
            let calendarDate = calendar.date(from: day.components)!

            let image = homeViewModel.photos.filter {
                calendar.isDate($0.date!, inSameDayAs: calendarDate)
            }.first

            if let image = image {
                selectedImage = image
                // TODO: action에 유저 액션? 아니면 행해야하는 액션?
                homeViewModel.perform(action: .photoTapped)
            } else if calendar.isDateInToday(calendarDate) {
                isShowingCamera = true
            }

            print(day.day)
        }

        .onAppear {
            calendarViewProxy.scrollToMonth(
                containing: .now,
                scrollPosition: .firstFullyVisiblePosition,
                animated: false
            )
        }

        .sheet(isPresented: $homeViewModel.isShowingDetailView) {
            ImageDetailView(
                homeViewModel: homeViewModel,
                selectedImage: $selectedImage
            )
        }
        .sheet(isPresented: $homeViewModel.isShowingMonthsSheet) {
            MonthsAvailable(calendarViewProxy: calendarViewProxy, startDate: visibleDateRange.lowerBound)
                .presentationDetents([.medium])
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}

struct MonthsAvailable: View {
    @ObservedObject var calendarViewProxy: CalendarViewProxy

    let startDate: Date

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Text("월 선택하기")
                    .font(.title).bold()

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title)
                }
            }
            .padding()

            ScrollView {
                ForEach(monthsBetween(start: Date(), end: startDate), id: \.self) { date in
                    HStack {
                        Text(formatDate(date))
                            .onTapGesture {
                                calendarViewProxy.scrollToMonth(
                                    containing: date,
                                    scrollPosition: .lastFullyVisiblePosition,
                                    animated: false
                                )

                                dismiss()
                            }
                            .font(.body)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 8)
                    .padding(4)
                }
            }
        }
    }

    // TODO: Extension으로 빼기
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }

    private func monthsBetween(start: Date, end: Date) -> [Date] {
        var result: [Date] = []
        var currentDate = start
        while currentDate >= end {
            result.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
        }
        return result
    }
}

#Preview {
    SmileCalendar(
        homeViewModel: HomeViewModel(),
        calendar: Calendar.current,
        monthsLayout: .horizontal(options: .init()),
        isShowingCamera: .constant(false)
    )
}
