//
//  SmileCalendarViewModel.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/06.
//

import Foundation

enum SmileCalendarViewModelAction {
    case showMonthsSheet
    case photoTapped
}

final class SmileCalendarViewModel: ObservableObject {
    // MARK: - Publihsers
    @Published var isShowingMonthsSheet = false
    @Published var isShowingDetailView = false

    init() {
        getImageList()
    }

    private func getImageList() {
        CoreDataStack.shared.getImageList()
    }

    // MARK: - Actions
    func perform(action: SmileCalendarViewModelAction) {
        switch action {
        case .showMonthsSheet:
            showMonthsSheet()
        case .photoTapped:
            showDetailView()
        }
    }

    // MARK: - Action Handlers
    private func showMonthsSheet() {
        isShowingMonthsSheet = true
    }

    private func showDetailView() {
        isShowingDetailView = true
    }

}
