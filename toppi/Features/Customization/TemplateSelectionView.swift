import SwiftUI

struct TemplateSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTemplate: ListTemplate
    @Binding var designSettings: DesignSettings
    
    let userTitle: String
    let userItems: [String]
    
    @State private var tempSelectedTemplate: ListTemplate
    
    init(selectedTemplate: Binding<ListTemplate>, designSettings: Binding<DesignSettings>, userTitle: String = "", userItems: [String] = []) {
        self._selectedTemplate = selectedTemplate
        self._designSettings = designSettings
        self.userTitle = userTitle
        self.userItems = userItems
        self._tempSelectedTemplate = State(initialValue: selectedTemplate.wrappedValue)
    }
    
    // Smart data logic
    private var displayTitle: String {
        return userTitle.isEmpty ? "Sample Title" : userTitle
    }
    
    private var displayItems: [String] {
        let nonEmptyItems = userItems.filter { !$0.isEmpty }
        return nonEmptyItems.isEmpty ? ["Sample Item 1", "Sample Item 2", "Sample Item 3"] : nonEmptyItems
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(ListTemplate.allCases, id: \.self) { template in
                            TemplateCardView(
                                template: template,
                                isSelected: tempSelectedTemplate == template,
                                displayTitle: displayTitle,
                                displayItems: displayItems
                            ) {
                                tempSelectedTemplate = template
                                AnalyticsService.shared.track(.templateSelected, properties: [
                                    "template": template.rawValue,
                                    "previous_template": selectedTemplate.rawValue
                                ])
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .onAppear {
            AnalyticsService.shared.trackScreenView("template_selection")
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .font(.body)
            
            Spacer()
            
            Text("Choose Template")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("Apply") {
                selectedTemplate = tempSelectedTemplate
                var newDesignSettings = tempSelectedTemplate.defaultSettings.toDesignSettings()
                newDesignSettings.templateType = tempSelectedTemplate.rawValue
                designSettings = newDesignSettings
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
}

struct TemplateCardView: View {
    let template: ListTemplate
    let isSelected: Bool
    let displayTitle: String
    let displayItems: [String]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Template preview
                ZStack {
                    RoundedRectangle(cornerRadius: template.defaultSettings.cornerRadius)
                        .fill(template.defaultSettings.backgroundUIColor)
                        .frame(height: 120)
                        .overlay(
                            VStack(spacing: 8) {
                                Text(displayTitle)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(template.defaultSettings.primaryUIColor)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                VStack(spacing: 4) {
                                    ForEach(Array(displayItems.prefix(3).enumerated()), id: \.offset) { index, item in
                                        HStack {
                                            Text("\(index + 1).")
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(template.defaultSettings.primaryUIColor)
                                            
                                            Text(item)
                                                .font(.system(size: 10))
                                                .foregroundColor(template.defaultSettings.primaryUIColor)
                                                .lineLimit(1)
                                            
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding(8)
                        )
                        .cornerRadius(template.defaultSettings.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: template.defaultSettings.cornerRadius)
                                .stroke(template.defaultSettings.secondaryUIColor, lineWidth: template.defaultSettings.borderWidth)
                        )
                        .shadow(
                            color: template.defaultSettings.shadowEnabled ? .black.opacity(0.1) : .clear,
                            radius: template.defaultSettings.shadowEnabled ? 4 : 0,
                            x: 0,
                            y: template.defaultSettings.shadowEnabled ? 2 : 0
                        )
                    
                    // Selection indicator
                    if isSelected {
                        RoundedRectangle(cornerRadius: template.defaultSettings.cornerRadius)
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
                
                // Template name
                Text(template.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            AnalyticsService.shared.track(.templatePreviewViewed, properties: ["template": template.rawValue])
        }
    }
}

// Extension to convert TemplateSettings to DesignSettings
extension TemplateSettings {
    func toDesignSettings() -> DesignSettings {
        return DesignSettings(
            templateType: "", // Will be set by the calling code
            backgroundColor: backgroundColor,
            useGradient: false,
            gradientColors: [primaryColor, secondaryColor],
            fontName: fontName,
            fontSize: fontSize,
            textColor: primaryColor,
            borderWidth: borderWidth,
            borderColor: secondaryColor,
            cornerRadius: cornerRadius
        )
    }
}

#Preview {
    TemplateSelectionView(
        selectedTemplate: .constant(.modern),
        designSettings: .constant(DesignSettings()),
        userTitle: "My Custom Title",
        userItems: ["Custom Item 1", "Custom Item 2", ""]
    )
} 