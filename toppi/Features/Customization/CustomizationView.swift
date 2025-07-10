import SwiftUI
import PhotosUI

struct CustomizationView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var designSettings: DesignSettings
    
    @State private var tempDesignSettings: DesignSettings
    @State private var showingImagePicker = false
    @State private var showingStockBackgroundPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    init(designSettings: Binding<DesignSettings>) {
        self._designSettings = designSettings
        self._tempDesignSettings = State(initialValue: designSettings.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Background section
                        backgroundSection
                        
                        // Colors section
                        colorsSection
                        
                        // Stickers section
                        stickersSection
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingStockBackgroundPicker) {
            StockBackgroundPickerView(designSettings: $tempDesignSettings)
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let newItem = newItem {
                    await loadSelectedPhoto(newItem)
                }
            }
        }
        .onAppear {
            AnalyticsService.shared.trackScreenView("customization")
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .font(.body)
            
            Spacer()
            
            Text("Customize")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("Apply") {
                designSettings = tempDesignSettings
                dismiss()
            }
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(.accentColor)
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }
    
    private var backgroundSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Background")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Background type toggle
                HStack {
                    Button {
                        tempDesignSettings.useGradient = false
                        AnalyticsService.shared.track(.backgroundColorChanged)
                    } label: {
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: tempDesignSettings.backgroundColor))
                                .frame(width: 60, height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(tempDesignSettings.useGradient ? .clear : .accentColor, lineWidth: 2)
                                )
                            
                            Text("Color")
                                .font(.caption)
                                .foregroundColor(tempDesignSettings.useGradient ? .secondary : .primary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button {
                        tempDesignSettings.useGradient = true
                        AnalyticsService.shared.track(.gradientApplied)
                    } label: {
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: tempDesignSettings.gradientColors.map { Color(hex: $0) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(tempDesignSettings.useGradient ? Color.accentColor : .clear, lineWidth: 2)
                                )
                            
                            Text("Gradient")
                                .font(.caption)
                                .foregroundColor(tempDesignSettings.useGradient ? .primary : .secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button {
                        showingStockBackgroundPicker = true
                        AnalyticsService.shared.track(.buttonTapped, properties: ["button_name": "stock_background"])
                    } label: {
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 40)
                                .overlay(
                                    Image(systemName: "photo.stack")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                )
                            
                            Text("Stock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 40)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                )
                            
                            Text("Upload")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Color picker (when color is selected)
                if !tempDesignSettings.useGradient {
                    ColorPickerGrid(selectedColor: $tempDesignSettings.backgroundColor)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var colorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Text Color")
                .font(.headline)
                .fontWeight(.semibold)
            
            ColorPickerGrid(selectedColor: $tempDesignSettings.textColor)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var stickersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stickers")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                ForEach(StickerPack.basic.stickers, id: \.self) { sticker in
                    Button {
                        addSticker(sticker)
                    } label: {
                        Text(sticker)
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func addSticker(_ sticker: String) {
        let newSticker = StickerItem(
            name: sticker,
            position: CGPoint(x: 200, y: 200),
            scale: 1.0,
            rotation: 0.0
        )
        tempDesignSettings.stickers.append(newSticker)
        AnalyticsService.shared.track(.stickerAdded, properties: ["sticker": sticker])
    }
    
    private func loadSelectedPhoto(_ item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                await MainActor.run {
                    tempDesignSettings.backgroundImageData = data
                    tempDesignSettings.backgroundImageName = nil
                    tempDesignSettings.useGradient = false
                    
                    AnalyticsService.shared.track(.backgroundImageUploaded, properties: ["source": "photo_library"])
                }
            }
        } catch {
            print("Failed to load photo: \(error)")
        }
    }
}

struct ColorPickerGrid: View {
    @Binding var selectedColor: String
    
    private let colors = [
        "#FFFFFF", "#F8F9FA", "#E9ECEF", "#DEE2E6", "#CED4DA", "#ADB5BD",
        "#6C757D", "#495057", "#343A40", "#212529", "#000000", "#FF6B6B",
        "#4ECDC4", "#45B7D1", "#F9CA24", "#F0932B", "#EB4D4B", "#6C5CE7",
        "#A29BFE", "#FD79A8", "#E17055", "#00B894", "#00CEC9", "#0984E3",
        "#B2BEC3", "#636E72", "#2D3436", "#74B9FF", "#81ECEC", "#A29BFE"
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
            ForEach(colors, id: \.self) { color in
                Button {
                    selectedColor = color
                } label: {
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.accentColor : .clear, lineWidth: 3)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct StickerPack {
    let name: String
    let stickers: [String]
    
    static let basic = StickerPack(
        name: "Basic",
        stickers: [
            "⭐️", "🎉", "🔥", "💯", "❤️", "👍", "🎈", "🎊",
            "🏆", "🌟", "💎", "🎯", "🚀", "✨", "🎪", "🎭"
        ]
    )
}

#Preview {
    CustomizationView(designSettings: .constant(DesignSettings()))
} 