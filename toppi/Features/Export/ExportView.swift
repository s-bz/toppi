import SwiftUI
import UIKit

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    
    let listItem: ListItem
    @State private var selectedFormat = ExportFormat.instagramPost
    @State private var generatedImage: UIImage?
    @State private var isGenerating = false
    @State private var showingShareSheet = false
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Format selection
                        formatSelectionSection
                        
                        // Preview
                        previewSection
                        
                        // Export buttons
                        exportButtonsSection
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = generatedImage {
                ShareSheet(items: [image])
            }
        }
        .alert("Saved!", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Your list has been saved to Photos.")
        }
        .onAppear {
            AnalyticsService.shared.trackScreenView("export")
            generateImage()
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .font(.body)
            
            Spacer()
            
            Text("Export List")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .font(.body)
            .fontWeight(.semibold)
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
    
    private var formatSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Export Format")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Button {
                        selectedFormat = format
                        generateImage()
                        AnalyticsService.shared.track(.exportFormatSelected, properties: [
                            "format": format.rawValue,
                            "previous_format": selectedFormat.rawValue
                        ])
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: format.icon)
                                .font(.title2)
                                .foregroundColor(selectedFormat == format ? .white : .primary)
                            
                            Text(format.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedFormat == format ? .white : .primary)
                            
                            Text("\(Int(format.size.width))×\(Int(format.size.height))")
                                .font(.caption2)
                                .foregroundColor(selectedFormat == format ? .white.opacity(0.8) : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedFormat == format ? Color.accentColor : Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedFormat == format ? .clear : Color(.systemGray4), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preview")
                .font(.headline)
                .fontWeight(.semibold)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .aspectRatio(selectedFormat.aspectRatio, contentMode: .fit)
                
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .scaleEffect(1.5)
                } else if let image = generatedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Text("Generating preview...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var exportButtonsSection: some View {
        VStack(spacing: 16) {
            // Share button
            Button {
                if generatedImage != nil {
                    showingShareSheet = true
                    AnalyticsService.shared.track(.shareButtonTapped, properties: [
                        "format": selectedFormat.rawValue,
                        "list_id": listItem.id.uuidString
                    ])
                }
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                    Text("Share")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(generatedImage != nil ? Color.accentColor : Color.gray)
                .cornerRadius(12)
            }
            .disabled(generatedImage == nil)
            
            // Save to Photos button
            Button {
                saveToPhotos()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title2)
                    Text("Save to Photos")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            .disabled(generatedImage == nil)
        }
    }
    
    private func generateImage() {
        isGenerating = true
        generatedImage = nil
        
        Task {
            let image = await ImageProcessingService.shared.generateImage(from: listItem, format: selectedFormat)
            
            await MainActor.run {
                self.generatedImage = image
                self.isGenerating = false
                
                if image != nil {
                    AnalyticsService.shared.track(.listExported, properties: [
                        "format": selectedFormat.rawValue,
                        "list_id": listItem.id.uuidString
                    ])
                }
            }
        }
    }
    
    private func saveToPhotos() {
        guard let image = generatedImage else { return }
        
        Task {
            do {
                try await ImageProcessingService.shared.saveToPhotos(image)
                await MainActor.run {
                    showingSuccessAlert = true
                    AnalyticsService.shared.track(.saveToPhotos, properties: [
                        "format": selectedFormat.rawValue,
                        "list_id": listItem.id.uuidString
                    ])
                }
            } catch {
                // Handle error - could show an alert
                print("Failed to save to photos: \(error)")
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed, let activityType = activityType {
                let platform = activityType.rawValue
                AnalyticsService.shared.track(.shareCompleted, properties: [
                    "platform": platform,
                    "success": completed
                ])
                
                // Track specific platforms
                if platform.contains("instagram") {
                    AnalyticsService.shared.track(.shareToInstagram)
                } else if platform.contains("tiktok") {
                    AnalyticsService.shared.track(.shareToTikTok)
                } else if platform.contains("twitter") {
                    AnalyticsService.shared.track(.shareToTwitter)
                }
            }
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let sampleList = ListItem(
        title: "My Favorite Movies",
        items: ["The Shawshank Redemption", "The Godfather", "Pulp Fiction", "The Dark Knight"],
        designSettings: DesignSettings()
    )
    
    return ExportView(listItem: sampleList)
} 