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

struct SmileCalendar: View {
    @StateObject private var smileCalendarViewModel = SmileCalendarViewModel()
    @StateObject private var calendarViewProxy = CalendarViewProxy()

    private let calendar: Calendar
    private let monthsLayout: MonthsLayout
    private let visibleDateRange: ClosedRange<Date>
    private let monthDateFormatter: DateFormatter

    @State private var selectedImage: Photo?
    @Binding var isShowingCamera: Bool

    init(calendar: Calendar, monthsLayout: MonthsLayout, isShowingCamera: Binding<Bool>) {
        self.calendar = calendar
        self.monthsLayout = monthsLayout
        let today = Date()

        let startDate = calendar.date(byAdding: .year, value: -10, to: today)!
        let endDate = calendar.date(byAdding: .year, value: 10, to: today)!
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
            dataDependency: nil,
            proxy: calendarViewProxy
        )
        .backgroundColor(.systemGray6)
        // TODO: Margin 처리하기 !
        .horizontalDayMargin(0)
        .verticalDayMargin(12)

        .monthHeaders { month in
            let monthHeaderText = monthDateFormatter.string(from: calendar.date(from: month.components)!)
            Button {
                smileCalendarViewModel.perform(action: .showMonthsSheet)
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
            switch weekdayIndex {
            case 0:
                Text("일").bold()
            case 1:
                Text("월").bold()
            case 2:
                Text("화").bold()
            case 3:
                Text("수").bold()
            case 4:
                Text("목").bold()
            case 5:
                Text("금").bold()
            case 6:
                Text("토").bold()
            default:
                Text("N/A")
            }
        }
        .days { day in
            Text("\(day.day)")
                .bold()
        }
        .dayBackgrounds({ day in
            let calendarDate = calendar.date(from: day.components)!
            let image = CoreDataStack.shared.imageList.filter {
                calendar.isDate($0.date!, inSameDayAs: calendarDate)
            }.first

            if let image = image {
                let uiImage = UIImage(data: image.blob!)!
                let imageView = Image(uiImage: uiImage)

                imageView
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        })
        .onDaySelection { day in
            let calendarDate = calendar.date(from: day.components)!

            let image = CoreDataStack.shared.imageList.filter {
                calendar.isDate($0.date!, inSameDayAs: calendarDate)
            }.first

            if let image = image {
                selectedImage = image
                // TODO: action에 유저 액션? 아니면 행해야하는 액션?
                smileCalendarViewModel.perform(action: .photoTapped)
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

        .sheet(isPresented: $smileCalendarViewModel.isShowingDetailView) {
            ImageDetailView(
                selectedImage: selectedImage
            )
        }
        .sheet(isPresented: $smileCalendarViewModel.isShowingMonthsSheet) {
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
    SmileCalendar(calendar: Calendar.current, monthsLayout: .horizontal(options: .init()), isShowingCamera: .constant(false))
}
