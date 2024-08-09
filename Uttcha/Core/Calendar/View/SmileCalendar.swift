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
        CalendarViewRepresentable(
            calendar: calendar,
            visibleDateRange: visibleDateRange,
            monthsLayout: monthsLayout,
            dataDependency: homeViewModel.photos,
            proxy: calendarViewProxy
        )
        .horizontalDayMargin(8)
        .verticalDayMargin(20)
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
                        .font(.callout)

                }
                .padding()
            }
        }
        .dayOfWeekHeaders { month, weekdayIndex in
            Text(dayNames[weekdayIndex]).bold()
        }
        .days { day in
            if let date = calendar.date(from: day.components) {
                let isToday = calendar.isDate(Date.now, inSameDayAs: date)
                let isFuture = date > Date.now
                let hasPhoto = isToday && homeViewModel.photos.contains { photo in
                    guard let photoDate = photo.dateCreated else { return false }
                    return calendar.isDate(photoDate, inSameDayAs: date)
                }

                if isToday && !hasPhoto {
                    ZStack(alignment: .center) {
                        Circle()
                            .foregroundStyle(.white)
                            .aspectRatio(1, contentMode: .fill)
                        Text("\(day.day)")
                            .foregroundStyle(.black)
                            .bold()
                    }
                } else {
                    Text("\(day.day)")
                        .foregroundStyle(isFuture ? .gray : .primary)
                        .bold()
                }

            }
        }
        .dayAspectRatio(1)
        .dayBackgrounds { day in
            if let calendarDate = calendar.date(from: day.components),
               let photo = homeViewModel.photos.first(where: { photoItem in
                   guard let photoDate = photoItem.dateCreated else { return false }
                   return calendar.isDate(photoDate, inSameDayAs: calendarDate)}),
               let imageData = photo.imageData,
               let date = photo.dateCreated {
                KFImage
                    .data(imageData, cacheKey: date.description)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                EmptyView()
            }
        }
        .onDaySelection { day in
            if let calendarDate = calendar.date(from: day.components) {
                if let photo = homeViewModel.photos.first(where: { photoItem in
                    guard let photoDate = photoItem.dateCreated else { return false }
                    return calendar.isDate(photoDate, inSameDayAs: calendarDate)
                }) {
                    homeViewModel.selectedPhoto = photo
                    homeViewModel.perform(action: .photoTapped)
                } else if calendar.isDateInToday(calendarDate) {
                    isShowingCamera = true
                }
            }
        }
        .onScroll { visibleDayRange, _ in
            homeViewModel.perform(action: .userScroll(visibleDayRange.lowerBound.components,
                                                      visibleDayRange.upperBound.components))
        }
        .sheet(item: $homeViewModel.presentedSheet) { sheet in
            switch sheet {
            case .photoDetail:
                PhotoDetailView(homeViewModel: homeViewModel)
            case .monthsAvailable:
                MonthsAvailable(calendarViewProxy: calendarViewProxy,
                                homeViewModel: homeViewModel,
                                startDate: visibleDateRange.lowerBound)
                    .presentationDetents([.medium])
            }
        }
        .onAppear {
            calendarViewProxy.scrollToMonth(
                containing: .now,
                scrollPosition: .firstFullyVisiblePosition,
                animated: false
            )
        }
    }
}

struct MonthsAvailable: View {
    @ObservedObject var calendarViewProxy: CalendarViewProxy
    @ObservedObject var homeViewModel: HomeViewModel

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
                            .font(.body)
                            .onTapGesture {
                                calendarViewProxy.scrollToMonth(
                                    containing: date,
                                    scrollPosition: .lastFullyVisiblePosition,
                                    animated: false
                                )
                                homeViewModel.perform(action: .monthRowTapped(date))

                                dismiss()
                            }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 8)
                    .padding(4)
                }
            }
        }
    }

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
    UttchaTapView()
}

#Preview {
    SmileCalendar(
        homeViewModel: HomeViewModel(),
        calendar: Calendar.current,
        monthsLayout: .horizontal(options: .init()),
        isShowingCamera: .constant(false)
    )
}
