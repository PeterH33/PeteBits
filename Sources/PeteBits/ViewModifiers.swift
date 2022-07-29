//
//  ViewModifiers.swift
//  
//
//  Created by Peter Hartnett on 7/14/22.
// test change

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
    ///Use this View Modifier to add a x.circle.fill button to a textfield that will clear the field when clicked.
    func textFieldClearButton(text: Binding<String>) -> some View {
        return self.modifier(TextFieldClearButton(text: text))
    }
}



@available(iOS 13.0, *)
public extension View {
    ///This will remove the iPad style navigation from large format iPhones.
    @ViewBuilder func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.navigationViewStyle(.stack)
        } else {
            self
        }
    }
}

///This is a correction of the apple api that allows you to change the frame of picker scroll wheel.
///
//I am not certain that this is setup correctly to function but shall test soon.
extension UIPickerView {
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
}
