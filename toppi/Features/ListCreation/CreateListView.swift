import SwiftUI
import SwiftData

struct CreateListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var listTitle = ""
    @State private var listItems = ["", "", "", "", ""]
    @State private var currentTemplate = ListTemplate.modern
    @State private var designSettings = {
        var settings = ListTemplate.modern.defaultSettings.toDesignSettings()
        settings.templateType = ListTemplate.modern.rawValue
        return settings
    }()
    @State private var showingTemplateSelector = false
    @State private var showingCustomization = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Title input
                        titleInputSection
                        
                        // Items input
                        itemsInputSection
                        
                        // Template preview
                        templatePreviewSection
                        
                        // Customization buttons
                        customizationSection
                        
                        // Save button
                        saveButtonSection
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingTemplateSelector) {
            TemplateSelectionView(selectedTemplate: $currentTemplate, designSettings: $designSettings, userTitle: listTitle, userItems: listItems)
        }
        .sheet(isPresented: $showingCustomization) {
            CustomizationView(designSettings: $designSettings)
        }
        .onAppear {
            AnalyticsService.shared.track(.screenView, properties: ["screen_name": "create_list"])
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .font(.body)
            
            Spacer()
            
            Text("Create List")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("Save") {
                saveList()
            }
            .font(.body)
            .fontWeight(.semibold)
            .disabled(listTitle.isEmpty || listItems.filter { !$0.isEmpty }.isEmpty)
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
    
    private var titleInputSection: some View {
        HStack(spacing: 16) {
            Text("List Title")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(width: 80, alignment: .leading)
            
            TextField("e.g., Top 5 Movies", text: $listTitle)
                .textFieldStyle(.roundedBorder)
                .font(.body)
                .onChange(of: listTitle) { oldValue, newValue in
                    if newValue != oldValue {
                        AnalyticsService.shared.track(.listTitleChanged, properties: ["length": newValue.count])
                    }
                }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var itemsInputSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack {
                Text("List Items")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 8)
            
            // Items list
            VStack(spacing: 1) {
                ForEach(0..<5, id: \.self) { index in
                    HStack(spacing: 16) {
                        Text("\(index + 1).")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(width: 20, alignment: .leading)
                        
                        TextField("Enter item \(index + 1)", text: $listItems[index])
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                            .onChange(of: listItems[index]) { oldValue, newValue in
                                if newValue != oldValue {
                                    let eventName = newValue.isEmpty ? AnalyticsEvent.listItemRemoved : (oldValue.isEmpty ? AnalyticsEvent.listItemAdded : AnalyticsEvent.listItemEdited)
                                    AnalyticsService.shared.track(eventName, properties: ["item_index": index])
                                }
                            }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    
                    if index < 4 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var templatePreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Button {
                showingTemplateSelector = true
                AnalyticsService.shared.track(.buttonTapped, properties: ["button_name": "template_selector"])
            } label: {
                ListPreviewView(
                    title: listTitle.isEmpty ? "Your List Title" : listTitle,
                    items: listItems.filter { !$0.isEmpty },
                    designSettings: designSettings,
                    template: currentTemplate
                )
                .frame(height: 240)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var customizationSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Button {
                    showingTemplateSelector = true
                    AnalyticsService.shared.track(.buttonTapped, properties: ["button_name": "select_template"])
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "rectangle.3.offgrid")
                            .font(.title2)
                        Text("Template")
                            .font(.caption)
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
                
                Button {
                    showingCustomization = true
                    AnalyticsService.shared.track(.buttonTapped, properties: ["button_name": "customize_design"])
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "paintbrush")
                            .font(.title2)
                        Text("Customize")
                            .font(.caption)
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var saveButtonSection: some View {
        Button {
            saveList()
        } label: {
            Text("Create List")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(12)
        }
        .disabled(listTitle.isEmpty || listItems.filter { !$0.isEmpty }.isEmpty)
        .opacity(listTitle.isEmpty || listItems.filter { !$0.isEmpty }.isEmpty ? 0.6 : 1.0)
    }
    
    private func saveList() {
        let nonEmptyItems = listItems.filter { !$0.isEmpty }
        
        guard !listTitle.isEmpty && !nonEmptyItems.isEmpty else { return }
        
        // Update design settings with current template
        designSettings.templateType = currentTemplate.rawValue
        
        let newListItem = ListItem(
            title: listTitle,
            items: nonEmptyItems,
            designSettings: designSettings
        )
        
        modelContext.insert(newListItem)
        
        AnalyticsService.shared.track(.listCreated, properties: [
            "title_length": listTitle.count,
            "item_count": nonEmptyItems.count,
            "template": currentTemplate.rawValue
        ])
        
        dismiss()
    }
}

#Preview {
    CreateListView()
        .modelContainer(for: ListItem.self, inMemory: true)
} 