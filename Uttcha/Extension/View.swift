//
//  View.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/07.
//

import SwiftUI

// MARK: - LongPressButton

struct SupportsLongPress: PrimitiveButtonStyle {

    /// An action to execute on long press
    let longPressAction: () -> ()

    /// Whether the button is being pressed
    @State var isPressed: Bool = false

    func makeBody(configuration: Configuration) -> some View {

        // The "label" as specified when declaring the button
        configuration.label

            // Visual feedback that the button is being pressed
            .opacity(self.isPressed ? 0.5 : 1.0)  // Adjust opacity here

            .onTapGesture {

                // Run the "action" as specified
                // when declaring the button
                configuration.trigger()

            }

            .onLongPressGesture(

                perform: {

                    // Run the action specified
                    // when using this style
                    self.longPressAction()

                },

                onPressingChanged: { pressing in

                    // Use "pressing" to infer whether the button
                    // is being pressed
                    self.isPressed = pressing

                }

            )

    }

}
/// A modifier that applies the `SupportsLongPress` style to buttons
struct SupportsLongPressModifier: ViewModifier {
    let longPressAction: () -> ()
    func body(content: Content) -> some View {
        content.buttonStyle(SupportsLongPress(longPressAction: self.longPressAction))
    }
}

/// Extend the View protocol for a SwiftUI-like shorthand version
extension View {
    func supportsLongPress(longPressAction: @escaping () -> ()) -> some View {
        modifier(SupportsLongPressModifier(longPressAction: longPressAction))
    }
}
