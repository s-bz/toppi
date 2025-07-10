import Foundation
import SwiftData
import SwiftUI

@Model
final class DesignSettings {
    var templateType: String
    var backgroundColor: String
    var backgroundImageName: String?
    var backgroundImageData: Data?
    var useGradient: Bool
    var gradientColors: [String]
    var fontName: String
    var fontSize: Double
    var textColor: String
    var stickers: [StickerItem]
    var exportFormat: String
    var borderWidth: Double
    var borderColor: String
    var cornerRadius: Double
    
    init(
        templateType: String = "modern",
        backgroundColor: String = "#FFFFFF",
        backgroundImageName: String? = nil,
        backgroundImageData: Data? = nil,
        useGradient: Bool = false,
        gradientColors: [String] = ["#FF6B6B", "#4ECDC4"],
        fontName: String = "system",
        fontSize: Double = 24.0,
        textColor: String = "#000000",
        stickers: [StickerItem] = [],
        exportFormat: String = "instagram-post",
        borderWidth: Double = 0,
        borderColor: String = "#000000",
        cornerRadius: Double = 16
    ) {
        self.templateType = templateType
        self.backgroundColor = backgroundColor
        self.backgroundImageName = backgroundImageName
        self.backgroundImageData = backgroundImageData
        self.useGradient = useGradient
        self.gradientColors = gradientColors
        self.fontName = fontName
        self.fontSize = fontSize
        self.textColor = textColor
        self.stickers = stickers
        self.exportFormat = exportFormat
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
    }
}

@Model
final class StickerItem {
    var id: UUID
    var name: String
    var positionX: Double
    var positionY: Double
    var scale: Double
    var rotation: Double
    
    init(name: String, position: CGPoint = .zero, scale: Double = 1.0, rotation: Double = 0.0) {
        self.id = UUID()
        self.name = name
        self.positionX = position.x
        self.positionY = position.y
        self.scale = scale
        self.rotation = rotation
    }
    
    var position: CGPoint {
        get { CGPoint(x: positionX, y: positionY) }
        set { 
            positionX = newValue.x
            positionY = newValue.y
        }
    }
} 