import Foundation
import SwiftUI

enum ListTemplate: String, CaseIterable {
    case modern = "modern"
    case minimalist = "minimalist"
    case pop = "pop"
    case vintage = "vintage"
    case neon = "neon"
    case handwritten = "handwritten"
    case professional = "professional"
    case polaroid = "polaroid"
    case comic = "comic"
    case gradient = "gradient"
    
    var displayName: String {
        switch self {
        case .modern:
            return "Modern"
        case .minimalist:
            return "Minimalist"
        case .pop:
            return "Pop"
        case .vintage:
            return "Vintage"
        case .neon:
            return "Neon"
        case .handwritten:
            return "Handwritten"
        case .professional:
            return "Professional"
        case .polaroid:
            return "Polaroid"
        case .comic:
            return "Comic"
        case .gradient:
            return "Gradient"
        }
    }
    
    var previewImage: String {
        return "template-\(rawValue)"
    }
    
    var defaultSettings: TemplateSettings {
        switch self {
        case .modern:
            return TemplateSettings(
                backgroundColor: "#FFFFFF",
                primaryColor: "#2C3E50",
                secondaryColor: "#34495E",
                fontName: "system",
                fontSize: 24,
                cornerRadius: 16,
                shadowEnabled: true,
                borderWidth: 0
            )
        case .minimalist:
            return TemplateSettings(
                backgroundColor: "#F8F9FA",
                primaryColor: "#212529",
                secondaryColor: "#6C757D",
                fontName: "system",
                fontSize: 20,
                cornerRadius: 16,
                shadowEnabled: false,
                borderWidth: 0
            )
        case .pop:
            return TemplateSettings(
                backgroundColor: "#FF6B6B",
                primaryColor: "#FFFFFF",
                secondaryColor: "#FFE66D",
                fontName: "system-bold",
                fontSize: 28,
                cornerRadius: 16,
                shadowEnabled: true,
                borderWidth: 3
            )
        case .vintage:
            return TemplateSettings(
                backgroundColor: "#F4F1DE",
                primaryColor: "#3D405B",
                secondaryColor: "#81B29A",
                fontName: "system-serif",
                fontSize: 22,
                cornerRadius: 16,
                shadowEnabled: false,
                borderWidth: 2
            )
        case .neon:
            return TemplateSettings(
                backgroundColor: "#0F0F0F",
                primaryColor: "#00FFF0",
                secondaryColor: "#FF00FF",
                fontName: "system-bold",
                fontSize: 26,
                cornerRadius: 16,
                shadowEnabled: true,
                borderWidth: 1
            )
        case .handwritten:
            return TemplateSettings(
                backgroundColor: "#FFFEF7",
                primaryColor: "#2F4F4F",
                secondaryColor: "#8B4513",
                fontName: "system-handwritten",
                fontSize: 24,
                cornerRadius: 16,
                shadowEnabled: false,
                borderWidth: 0
            )
        case .professional:
            return TemplateSettings(
                backgroundColor: "#FFFFFF",
                primaryColor: "#1F2937",
                secondaryColor: "#4B5563",
                fontName: "system",
                fontSize: 22,
                cornerRadius: 16,
                shadowEnabled: true,
                borderWidth: 1
            )
        case .polaroid:
            return TemplateSettings(
                backgroundColor: "#FFFFFF",
                primaryColor: "#2C3E50",
                secondaryColor: "#7F8C8D",
                fontName: "system",
                fontSize: 20,
                cornerRadius: 16,
                shadowEnabled: true,
                borderWidth: 8
            )
        case .comic:
            return TemplateSettings(
                backgroundColor: "#FFEB3B",
                primaryColor: "#E91E63",
                secondaryColor: "#9C27B0",
                fontName: "system-bold",
                fontSize: 24,
                cornerRadius: 16,
                shadowEnabled: true,
                borderWidth: 4
            )
        case .gradient:
            return TemplateSettings(
                backgroundColor: "#667eea",
                primaryColor: "#FFFFFF",
                secondaryColor: "#f093fb",
                fontName: "system",
                fontSize: 24,
                cornerRadius: 16,
                shadowEnabled: true,
                borderWidth: 0
            )
        }
    }
}

struct TemplateSettings {
    let backgroundColor: String
    let primaryColor: String
    let secondaryColor: String
    let fontName: String
    let fontSize: Double
    let cornerRadius: Double
    let shadowEnabled: Bool
    let borderWidth: Double
    
    var backgroundUIColor: Color {
        Color(hex: backgroundColor)
    }
    
    var primaryUIColor: Color {
        Color(hex: primaryColor)
    }
    
    var secondaryUIColor: Color {
        Color(hex: secondaryColor)
    }
}

// Extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 