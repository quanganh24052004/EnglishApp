//
//  ButtonStyles.swift
//  EnglishApp
//
//  Các ButtonStyle tái sử dụng cho toàn bộ ứng dụng
//

import SwiftUI

// MARK: - PhysicalButtonStyle (Nút chính - Có màu nền)

struct PhysicalButtonStyle: ButtonStyle {
    var textSize: CGFloat = 16
    var textColor: Color = .primaryBG
    var backgroundColor: Color = .brand
    var shadowColor: Color = .shadow
    var heightShadow: CGFloat = 4
    var height: CGFloat = 48
    var cornerRadius: CGFloat = 16

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(shadowColor)
                .offset(y: heightShadow)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .padding()

            configuration.label
                .font(.system(size: textSize, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                )
                .padding()
                .offset(y: configuration.isPressed ? heightShadow : 0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
        }
        .frame(height: height + heightShadow)
    }
}

// MARK: - SecondaryPhysicalButtonStyle (Nút phụ - Viền + nền trắng)

struct SecondaryPhysicalButtonStyle: ButtonStyle {
    var textSize: CGFloat = 16
    var textColor: Color = Color.brand
    var backgroundColor: Color = Color.primaryBG
    var heightShadow: CGFloat = 4
    var height: CGFloat = 48
    var cornerRadius: CGFloat = 16
    var strokeWidth: CGFloat = 2
    var strokeColor: Color = .strokeBtn

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(strokeColor)
                .offset(y: heightShadow)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .padding()

            configuration.label
                .font(.system(size: textSize, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(strokeColor, lineWidth: strokeWidth)
                        )
                )
                .padding()
                .offset(y: configuration.isPressed ? heightShadow : 0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
        }
        .frame(height: height + heightShadow)
    }
}

// MARK: - Convenience Extensions

extension ButtonStyle where Self == PhysicalButtonStyle {
    static var physical: PhysicalButtonStyle { PhysicalButtonStyle() }
}

extension ButtonStyle where Self == SecondaryPhysicalButtonStyle {
    static var physicalSecondary: SecondaryPhysicalButtonStyle { SecondaryPhysicalButtonStyle() }
}
