import SwiftUI

struct StockBackgroundPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var designSettings: DesignSettings
    @StateObject private var stockService = StockBackgroundService.shared
    
    @State private var selectedCategory: StockBackgroundCategory = .gradient
    @State private var selectedBackground: StockBackground?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                
                VStack(spacing: 0) {
                    // Category selector
                    categorySelector
                    
                    // Background grid
                    backgroundGrid
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .onAppear {
            AnalyticsService.shared.trackScreenView("stock_background_picker")
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .font(.body)
            
            Spacer()
            
            Text("Choose Background")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("Apply") {
                if let background = selectedBackground {
                    applyBackground(background)
                }
                dismiss()
            }
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(.accentColor)
            .disabled(selectedBackground == nil)
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
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(StockBackgroundCategory.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.title2)
                                .foregroundColor(selectedCategory == category ? .accentColor : .secondary)
                            
                            Text(category.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedCategory == category ? .accentColor : .secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedCategory == category ? Color.accentColor.opacity(0.1) : Color.clear)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }
    
    private var backgroundGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(stockService.stockBackgrounds.filter { $0.category == selectedCategory }) { background in
                    Button {
                        selectedBackground = background
                        AnalyticsService.shared.track(.backgroundImageSelected, properties: [
                            "background": background.name,
                            "category": background.category.rawValue
                        ])
                    } label: {
                        VStack(spacing: 12) {
                            ZStack {
                                // Background preview
                                if let image = stockService.getBackgroundImage(name: background.name) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray4))
                                        .frame(height: 120)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .font(.title2)
                                                .foregroundColor(.secondary)
                                        )
                                }
                                
                                // Selection indicator
                                if selectedBackground == background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.accentColor, lineWidth: 3)
                                        .frame(height: 120)
                                    
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.accentColor)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                        }
                                        Spacer()
                                    }
                                    .padding(8)
                                }
                            }
                            
                            Text(background.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    
    private func applyBackground(_ background: StockBackground) {
        designSettings.backgroundImageName = background.name
        designSettings.backgroundImageData = nil
        designSettings.useGradient = false
        
        // Set appropriate background color based on the background
        if background.category == .solid {
            if background.name.contains("white") {
                designSettings.backgroundColor = "#FFFFFF"
                designSettings.textColor = "#000000"
            } else if background.name.contains("black") {
                designSettings.backgroundColor = "#000000"
                designSettings.textColor = "#FFFFFF"
            } else {
                designSettings.backgroundColor = "#F5F5F5"
                designSettings.textColor = "#000000"
            }
        } else {
            // For other backgrounds, use contrasting text
            designSettings.textColor = "#FFFFFF"
        }
    }
}

#Preview {
    StockBackgroundPickerView(designSettings: .constant(DesignSettings()))
} 