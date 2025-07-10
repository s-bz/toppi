import SwiftUI

class StockBackgroundService: ObservableObject {
    static let shared = StockBackgroundService()
    
    private init() {}
    
    let stockBackgrounds: [StockBackground] = [
        StockBackground(name: "gradient-blue", displayName: "Blue Gradient", category: .gradient),
        StockBackground(name: "gradient-sunset", displayName: "Sunset Gradient", category: .gradient),
        StockBackground(name: "gradient-purple", displayName: "Purple Gradient", category: .gradient),
        StockBackground(name: "gradient-green", displayName: "Green Gradient", category: .gradient),
        StockBackground(name: "solid-white", displayName: "White", category: .solid),
        StockBackground(name: "solid-black", displayName: "Black", category: .solid),
        StockBackground(name: "solid-gray", displayName: "Gray", category: .solid),
        StockBackground(name: "pattern-dots", displayName: "Dots Pattern", category: .pattern),
        StockBackground(name: "pattern-lines", displayName: "Lines Pattern", category: .pattern),
        StockBackground(name: "texture-paper", displayName: "Paper Texture", category: .texture),
        StockBackground(name: "texture-fabric", displayName: "Fabric Texture", category: .texture),
        StockBackground(name: "nature-sky", displayName: "Sky", category: .nature),
        StockBackground(name: "nature-ocean", displayName: "Ocean", category: .nature),
        StockBackground(name: "nature-forest", displayName: "Forest", category: .nature),
        StockBackground(name: "abstract-waves", displayName: "Waves", category: .abstract),
        StockBackground(name: "abstract-shapes", displayName: "Shapes", category: .abstract)
    ]
    
    func getBackgroundsByCategory() -> [StockBackgroundCategory: [StockBackground]] {
        return Dictionary(grouping: stockBackgrounds, by: { $0.category })
    }
    
    func getBackgroundImage(name: String) -> UIImage? {
        // For now, return a programmatically generated image
        // In a real app, these would be actual image assets
        return generatePlaceholderImage(for: name)
    }
    
    private func generatePlaceholderImage(for name: String) -> UIImage? {
        let size = CGSize(width: 1080, height: 1080)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            if name.contains("gradient-blue") {
                let colors = [UIColor.blue.cgColor, UIColor.cyan.cgColor]
                drawGradient(in: cgContext, colors: colors, size: size)
            } else if name.contains("gradient-sunset") {
                let colors = [UIColor.orange.cgColor, UIColor.red.cgColor]
                drawGradient(in: cgContext, colors: colors, size: size)
            } else if name.contains("gradient-purple") {
                let colors = [UIColor.purple.cgColor, UIColor.magenta.cgColor]
                drawGradient(in: cgContext, colors: colors, size: size)
            } else if name.contains("gradient-green") {
                let colors = [UIColor.green.cgColor, UIColor.systemTeal.cgColor]
                drawGradient(in: cgContext, colors: colors, size: size)
            } else if name.contains("solid-white") {
                cgContext.setFillColor(UIColor.white.cgColor)
                cgContext.fill(CGRect(origin: .zero, size: size))
            } else if name.contains("solid-black") {
                cgContext.setFillColor(UIColor.black.cgColor)
                cgContext.fill(CGRect(origin: .zero, size: size))
            } else if name.contains("solid-gray") {
                cgContext.setFillColor(UIColor.systemGray.cgColor)
                cgContext.fill(CGRect(origin: .zero, size: size))
            } else if name.contains("pattern-dots") {
                drawDotPattern(in: cgContext, size: size)
            } else if name.contains("pattern-lines") {
                drawLinePattern(in: cgContext, size: size)
            } else if name.contains("texture-paper") {
                drawPaperTexture(in: cgContext, size: size)
            } else if name.contains("texture-fabric") {
                drawFabricTexture(in: cgContext, size: size)
            } else if name.contains("nature-sky") {
                let colors = [UIColor.systemBlue.cgColor, UIColor.white.cgColor]
                drawGradient(in: cgContext, colors: colors, size: size)
            } else if name.contains("nature-ocean") {
                let colors = [UIColor.systemTeal.cgColor, UIColor.systemBlue.cgColor]
                drawGradient(in: cgContext, colors: colors, size: size)
            } else if name.contains("nature-forest") {
                let colors = [UIColor.systemGreen.cgColor, UIColor.systemTeal.cgColor]
                drawGradient(in: cgContext, colors: colors, size: size)
            } else if name.contains("abstract-waves") {
                drawWavePattern(in: cgContext, size: size)
            } else if name.contains("abstract-shapes") {
                drawShapePattern(in: cgContext, size: size)
            } else {
                // Default to a light gray background
                cgContext.setFillColor(UIColor.systemGray6.cgColor)
                cgContext.fill(CGRect(origin: .zero, size: size))
            }
        }
    }
    
    private func drawGradient(in context: CGContext, colors: [CGColor], size: CGSize) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil) else { return }
        
        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: size.width, y: size.height)
        
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
    }
    
    private func drawDotPattern(in context: CGContext, size: CGSize) {
        context.setFillColor(UIColor.systemGray6.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        context.setFillColor(UIColor.systemGray4.cgColor)
        let dotSize: CGFloat = 20
        let spacing: CGFloat = 40
        
        for x in stride(from: 0, to: size.width, by: spacing) {
            for y in stride(from: 0, to: size.height, by: spacing) {
                let dotRect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                context.fillEllipse(in: dotRect)
            }
        }
    }
    
    private func drawLinePattern(in context: CGContext, size: CGSize) {
        context.setFillColor(UIColor.systemGray6.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        context.setStrokeColor(UIColor.systemGray4.cgColor)
        context.setLineWidth(2)
        
        let spacing: CGFloat = 30
        for x in stride(from: 0, to: size.width, by: spacing) {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: size.height))
            context.strokePath()
        }
    }
    
    private func drawPaperTexture(in context: CGContext, size: CGSize) {
        context.setFillColor(UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0).cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Add some subtle noise for paper texture
        context.setFillColor(UIColor.systemGray5.cgColor)
        for _ in 0..<1000 {
            let x = CGFloat.random(in: 0...size.width)
            let y = CGFloat.random(in: 0...size.height)
            let dotSize = CGFloat.random(in: 1...3)
            context.fillEllipse(in: CGRect(x: x, y: y, width: dotSize, height: dotSize))
        }
    }
    
    private func drawFabricTexture(in context: CGContext, size: CGSize) {
        context.setFillColor(UIColor(red: 0.95, green: 0.94, blue: 0.92, alpha: 1.0).cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Add crosshatch pattern for fabric texture
        context.setStrokeColor(UIColor.systemGray4.cgColor)
        context.setLineWidth(1)
        
        let spacing: CGFloat = 20
        // Horizontal lines
        for y in stride(from: 0, to: size.height, by: spacing) {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: size.width, y: y))
            context.strokePath()
        }
        
        // Vertical lines
        for x in stride(from: 0, to: size.width, by: spacing) {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: size.height))
            context.strokePath()
        }
    }
    
    private func drawWavePattern(in context: CGContext, size: CGSize) {
        let colors = [UIColor.systemPurple.cgColor, UIColor.magenta.cgColor]
        drawGradient(in: context, colors: colors, size: size)
        
        // Add wave overlay
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(3)
        
        let waveHeight: CGFloat = 60
        let waveLength: CGFloat = 120
        
        for y in stride(from: 0, to: size.height, by: waveHeight * 2) {
            context.move(to: CGPoint(x: 0, y: y))
            
            for x in stride(from: 0, to: size.width, by: waveLength / 4) {
                let waveY = y + sin(x / waveLength * 2 * .pi) * waveHeight
                context.addLine(to: CGPoint(x: x, y: waveY))
            }
            
            context.strokePath()
        }
    }
    
    private func drawShapePattern(in context: CGContext, size: CGSize) {
        context.setFillColor(UIColor.systemIndigo.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Add geometric shapes
        context.setFillColor(UIColor.white.withAlphaComponent(0.2).cgColor)
        
        for _ in 0..<20 {
            let x = CGFloat.random(in: 0...size.width)
            let y = CGFloat.random(in: 0...size.height)
            let shapeSize = CGFloat.random(in: 30...80)
            
            if Bool.random() {
                // Circle
                context.fillEllipse(in: CGRect(x: x, y: y, width: shapeSize, height: shapeSize))
            } else {
                // Square
                context.fill(CGRect(x: x, y: y, width: shapeSize, height: shapeSize))
            }
        }
    }
}

struct StockBackground: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let displayName: String
    let category: StockBackgroundCategory
}

enum StockBackgroundCategory: String, CaseIterable {
    case gradient = "Gradients"
    case solid = "Solid Colors"
    case pattern = "Patterns"
    case texture = "Textures"
    case nature = "Nature"
    case abstract = "Abstract"
    
    var icon: String {
        switch self {
        case .gradient:
            return "paintbrush.fill"
        case .solid:
            return "square.fill"
        case .pattern:
            return "grid"
        case .texture:
            return "textformat"
        case .nature:
            return "leaf.fill"
        case .abstract:
            return "scribble"
        }
    }
} 