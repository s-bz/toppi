import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImageProcessingService: ObservableObject {
    static let shared = ImageProcessingService()
    
    private let ciContext = CIContext()
    
    private init() {}
    
    // Generate image from list item
    func generateImage(from listItem: ListItem, format: ExportFormat) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let image = self.createImageUsingCoreGraphics(for: listItem, format: format)
                continuation.resume(returning: image)
            }
        }
    }
    
    // Create image using Core Graphics
    private func createImageUsingCoreGraphics(for listItem: ListItem, format: ExportFormat) -> UIImage? {
        let size = format.size
        
        // Create renderer with high quality settings
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 2.0  // High DPI
        rendererFormat.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: size, format: rendererFormat)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // Set high quality rendering
            cgContext.setShouldAntialias(true)
            cgContext.setAllowsAntialiasing(true)
            cgContext.setShouldSmoothFonts(true)
            
            self.renderList(listItem, in: cgContext, size: size)
        }
    }
    
    // Render list content to Core Graphics context
    private func renderList(_ listItem: ListItem, in context: CGContext, size: CGSize) {
        // Set up the context
        context.saveGState()
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Apply background
        if let backgroundImage = loadBackgroundImage(from: listItem.designSettings) {
            drawBackgroundImage(backgroundImage, in: context, size: size)
        } else {
            drawBackgroundColor(listItem.designSettings.backgroundColor, in: context, size: size)
        }
        
        // Apply gradient if enabled
        if listItem.designSettings.useGradient {
            drawGradient(listItem.designSettings.gradientColors, in: context, size: size)
        }
        
        // Draw list content with proper styling from design settings
        drawListContent(listItem, in: context, size: size)
        
        // Draw border if specified
        if listItem.designSettings.borderWidth > 0 {
            drawBorder(listItem.designSettings, in: context, size: size)
        }
        
        // Draw stickers
        drawStickers(listItem.designSettings.stickers, in: context, size: size)
        
        context.restoreGState()
    }
    
    // Load background image from settings
    private func loadBackgroundImage(from settings: DesignSettings) -> UIImage? {
        if let imageData = settings.backgroundImageData {
            return UIImage(data: imageData)
        } else if let imageName = settings.backgroundImageName {
            // First try to load from bundle
            if let bundleImage = UIImage(named: imageName) {
                return bundleImage
            }
            // Then try to load from stock backgrounds
            return StockBackgroundService.shared.getBackgroundImage(name: imageName)
        }
        return nil
    }
    
    // Draw background color
    private func drawBackgroundColor(_ colorHex: String, in context: CGContext, size: CGSize) {
        let color = UIColor.from(hex: colorHex)
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
    }
    
    // Draw background image
    private func drawBackgroundImage(_ image: UIImage, in context: CGContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        if let cgImage = image.cgImage {
            context.draw(cgImage, in: rect)
        }
    }
    
    // Draw gradient overlay
    private func drawGradient(_ colors: [String], in context: CGContext, size: CGSize) {
        guard colors.count >= 2 else { return }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let uiColors = colors.map { UIColor.from(hex: $0) }
        let cgColors = uiColors.map { $0.cgColor }
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: nil) else { return }
        
        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: size.width, y: size.height)
        
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
    }
    
    // Draw border
    private func drawBorder(_ settings: DesignSettings, in context: CGContext, size: CGSize) {
        let borderColor = UIColor.from(hex: settings.borderColor)
        let borderWidth = settings.borderWidth
        let cornerRadius = settings.cornerRadius
        
        print("Drawing border: width=\(borderWidth), color=\(settings.borderColor), radius=\(cornerRadius)")
        
        guard borderWidth > 0 else { return }
        
        context.saveGState()
        
        // Set up the border drawing
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(borderWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        // Calculate the proper inset to ensure border is fully visible
        let inset = borderWidth / 2
        let borderRect = CGRect(
            x: inset, 
            y: inset, 
            width: size.width - borderWidth, 
            height: size.height - borderWidth
        )
        
        // Ensure corner radius doesn't exceed half the smallest dimension
        let maxRadius = min(borderRect.width, borderRect.height) / 2
        let adjustedRadius = min(cornerRadius, maxRadius)
        
        // Create the path with proper corner radius
        let path = UIBezierPath(roundedRect: borderRect, cornerRadius: adjustedRadius)
        
        // Draw the border
        context.addPath(path.cgPath)
        context.strokePath()
        
        context.restoreGState()
    }
    
    // Draw list content (title and items)
    private func drawListContent(_ listItem: ListItem, in context: CGContext, size: CGSize) {
        print("Drawing list content for: '\(listItem.title)' with \(listItem.items.count) items")
        print("Canvas size: \(size)")
        print("Text color: \(listItem.designSettings.textColor)")
        
        // Calculate layout with proper scaling for high-resolution export
        let margin: CGFloat = 80  // Increased from 40
        let titleHeight: CGFloat = 160  // Increased from 80
        let itemHeight: CGFloat = 120  // Increased from 60
        let spacing: CGFloat = 40  // Increased from 20
        
        let contentWidth = size.width - (margin * 2)
        
        var currentY = margin
        
        // Get text color from design settings
        let textColor = UIColor.from(hex: listItem.designSettings.textColor)
        
        // Draw title with much larger font
        let titleRect = CGRect(x: margin, y: currentY, width: contentWidth, height: titleHeight)
        drawText(listItem.title, in: titleRect, context: context, fontSize: 84, isBold: true, color: textColor)  // Increased from 32
        currentY += titleHeight + spacing
        
        // Draw items with larger font
        for (index, item) in listItem.items.enumerated() {
            let itemRect = CGRect(x: margin, y: currentY, width: contentWidth, height: itemHeight)
            let numberedItem = "\(index + 1). \(item)"
            drawText(numberedItem, in: itemRect, context: context, fontSize: 64, isBold: false, color: textColor)  // Increased from 24
            currentY += itemHeight + spacing
        }
        
        print("Finished drawing list content")
    }
    
    // Draw text in context
    private func drawText(_ text: String, in rect: CGRect, context: CGContext, fontSize: CGFloat, isBold: Bool, color: UIColor) {
        guard !text.isEmpty else { return }
        
        // Debug logging
        print("Drawing text: '\(text)' in rect: \(rect) with color: \(color)")
        
        let font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]
        
        // Set high quality text rendering
        context.saveGState()
        context.setShouldAntialias(true)
        context.setTextDrawingMode(.fill)
        context.setAllowsAntialiasing(true)
        context.setShouldSmoothFonts(true)
        
        // Use NSString drawing which handles coordinate system automatically
        let nsString = text as NSString
        nsString.draw(in: rect, withAttributes: attributes)
        
        context.restoreGState()
    }
    
    // Draw stickers
    private func drawStickers(_ stickers: [StickerItem], in context: CGContext, size: CGSize) {
        for sticker in stickers {
            guard let stickerImage = UIImage(named: sticker.name),
                  let cgImage = stickerImage.cgImage else { continue }
            
            let stickerSize = CGSize(width: 100 * sticker.scale, height: 100 * sticker.scale)
            let stickerRect = CGRect(
                x: sticker.position.x - stickerSize.width / 2,
                y: sticker.position.y - stickerSize.height / 2,
                width: stickerSize.width,
                height: stickerSize.height
            )
            
            context.saveGState()
            
            // Apply rotation
            if sticker.rotation != 0 {
                context.translateBy(x: sticker.position.x, y: sticker.position.y)
                context.rotate(by: sticker.rotation)
                context.translateBy(x: -sticker.position.x, y: -sticker.position.y)
            }
            
            context.draw(cgImage, in: stickerRect)
            context.restoreGState()
        }
    }
    
    // Save image to Photos
    func saveToPhotos(_ image: UIImage) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    continuation.resume(throwing: ImageProcessingError.photoLibraryAccessDenied)
                    return
                }
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCreationRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    if success {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: error ?? ImageProcessingError.saveFailed)
                    }
                }
            }
        }
    }
    
    // Compress image for sharing
    func compressImage(_ image: UIImage, quality: CGFloat = 0.8) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }
}

enum ImageProcessingError: Error {
    case photoLibraryAccessDenied
    case saveFailed
    case compressionFailed
    case invalidImage
}

// Safe UIColor extension for hex conversion
extension UIColor {
    static func from(hex: String) -> UIColor {
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
        return UIColor(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
} 