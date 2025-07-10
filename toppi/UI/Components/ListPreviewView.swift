import SwiftUI

struct ListPreviewView: View {
    let title: String
    let items: [String]
    let designSettings: DesignSettings
    let template: ListTemplate
    let showTitle: Bool
    
    init(title: String, items: [String], designSettings: DesignSettings, template: ListTemplate, showTitle: Bool = true) {
        self.title = title
        self.items = items
        self.designSettings = designSettings
        self.template = template
        self.showTitle = showTitle
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundView
            
            // Content
            VStack(spacing: showTitle ? 16 : 20) {
                // Title (conditional)
                if showTitle {
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: fontDesign))
                        .foregroundColor(Color(hex: designSettings.textColor))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 16)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Items
                VStack(spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        HStack {
                            Text("\(index + 1).")
                                .font(.system(size: 18, weight: .medium, design: fontDesign))
                                .foregroundColor(Color(hex: designSettings.textColor))
                                .frame(width: 30, alignment: .leading)
                            
                            Text(item)
                                .font(.system(size: 18, weight: .regular, design: fontDesign))
                                .foregroundColor(Color(hex: designSettings.textColor))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 20)
        }
        .cornerRadius(designSettings.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: designSettings.cornerRadius)
                .stroke(Color(hex: designSettings.borderColor), lineWidth: designSettings.borderWidth)
        )
        .shadow(
            color: template.defaultSettings.shadowEnabled ? .black.opacity(0.2) : .clear,
            radius: template.defaultSettings.shadowEnabled ? 8 : 0,
            x: 0,
            y: template.defaultSettings.shadowEnabled ? 4 : 0
        )
    }
    
    private var backgroundView: some View {
        Group {
            if designSettings.useGradient {
                LinearGradient(
                    colors: designSettings.gradientColors.map { Color(hex: $0) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else if let backgroundImageData = designSettings.backgroundImageData,
                      let uiImage = UIImage(data: backgroundImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let backgroundImageName = designSettings.backgroundImageName {
                if let bundleImage = UIImage(named: backgroundImageName) {
                    Image(uiImage: bundleImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if let stockImage = StockBackgroundService.shared.getBackgroundImage(name: backgroundImageName) {
                    Image(uiImage: stockImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            } else {
                Color(hex: designSettings.backgroundColor)
            }
        }
    }
    
    private var fontDesign: Font.Design {
        switch designSettings.fontName {
        case "system-serif":
            return .serif
        case "system-handwritten":
            return .rounded
        case "system-bold":
            return .default
        default:
            return .default
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ListPreviewView(
            title: "My Favorite Movies",
            items: ["The Shawshank Redemption", "The Godfather", "Pulp Fiction", "The Dark Knight"],
            designSettings: DesignSettings(),
            template: .modern
        )
        .frame(height: 200)
        
        ListPreviewView(
            title: "Top 5 Pizza Places",
            items: ["Joe's Pizza", "Di Fara", "Prince Street Pizza", "Lombardi's", "Roberta's"],
            designSettings: DesignSettings(
                backgroundColor: "#FF6B6B",
                useGradient: true,
                gradientColors: ["#FF6B6B", "#4ECDC4"],
                textColor: "#FFFFFF"
            ),
            template: .pop
        )
        .frame(height: 200)
    }
    .padding()
} 