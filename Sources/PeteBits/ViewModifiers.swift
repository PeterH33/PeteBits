//
//  ViewModifiers.swift
//  
//
//  Created by Peter Hartnett on 7/14/22.
//

import SwiftUI

///Use this View Modifier to add a x.circle.fill button to a textfield that will clear the field when clicked.
@available(iOS 13.0, *)
struct TextFieldClearButton: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        HStack {
            content
            if !text.isEmpty {
                Button(
                    action: { self.text = "" },
                    label: {
                        Image(systemName: "x.circle.fill")
                            .foregroundColor(.secondary)
                    }
                )
            }
        }
    }
}

@available(iOS 13.0, *)
public extension View {
    func textFieldClearButton(text: Binding<String>) -> some View {
        return self.modifier(TextFieldClearButton(text: text))
    }
}
