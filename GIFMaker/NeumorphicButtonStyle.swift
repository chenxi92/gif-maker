//
//  NeumorphicButtonStyle.swift
//  GIFMaker
//
//  Created by peak on 2022/8/12.
//

import SwiftUI

struct NeumorphicButtonStyle: ButtonStyle {
    var bgColor: Color
    var disable: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.system(size: 20, weight: .semibold))
            .padding(.horizontal)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .shadow(
                            color: .white,
                            radius: configuration.isPressed ? 7 : 10,
                            x: configuration.isPressed ? -5 : -15,
                            y: configuration.isPressed ? -5 : -15
                        )
                        .shadow(
                            color: .black,
                            radius: configuration.isPressed ? 7 : 10,
                            x: configuration.isPressed ? 5 : 15,
                            y: configuration.isPressed ? 5 : 15
                        )
                        .blendMode(.overlay)
                    
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(disable ? .gray.opacity(0.5) : bgColor)
                }
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .foregroundColor(disable ? .gray : .primary)
            .padding()
            .animation(.spring(), value: configuration.isPressed)
    }
}

