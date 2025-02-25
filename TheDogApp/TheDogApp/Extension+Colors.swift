//
//  Extension+Colors.swift
//  TheDogApp
//
//  Created by Joseluis SN on 25/02/25.
//

import SwiftUI

extension Color {
    static let background: Color = Color("Background")
    static let secondaryBackground: Color = Color("SecondaryBackground")
    static let tertiary: Color = Color("tertiary")
    static let darkText: Color = Color("darkText")
    
    static func borderColor(condition: Bool?)-> Color{
        switch condition {
        case .some(true):
            return Color.green.opacity(0.8)
        case .some(false):
            return Color.red.opacity(0.8)
        case .none:
            return Color.darkText.opacity(0.2)
        }
    }
}
