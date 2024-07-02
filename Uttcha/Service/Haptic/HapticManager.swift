//
//  HapticManager.swift
//  Uttcha
//
//  Created by KHJ on 7/2/24.
//

import UIKit

class HapticManager {
    static private let generator = UINotificationFeedbackGenerator()

    private static let impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [
        .light: UIImpactFeedbackGenerator(style: .light),
        .medium: UIImpactFeedbackGenerator(style: .medium),
        .heavy: UIImpactFeedbackGenerator(style: .heavy),
        .soft: UIImpactFeedbackGenerator(style: .soft),
        .rigid: UIImpactFeedbackGenerator(style: .rigid)
    ]

    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        generator.notificationOccurred(type)
    }

    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1.0) {
        guard let generator = impactGenerators[style] else { return }
        generator.impactOccurred(intensity: intensity)
    }
}
