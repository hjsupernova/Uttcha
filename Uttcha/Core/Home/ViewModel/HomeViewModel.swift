//
//  HomeViewModel.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/27.
//

import Foundation

enum HomeViewModelAction {
    case cameraButtonTapped

}

final class HomeViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var isShowingCameraView: Bool = false

    // MARK: - Actions
    func perform(action: HomeViewModelAction) {
        switch action {
        case .cameraButtonTapped:
            showCameraView()
        }
    }

    // MARK: - Action Handlers

    private func showCameraView() {
        isShowingCameraView = true
    }
}
