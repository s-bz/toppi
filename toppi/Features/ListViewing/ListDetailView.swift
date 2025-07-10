import SwiftUI
import SwiftData

struct ListDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var listItem: ListItem
    @State private var showingEditView = false
    @State private var showingExportView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // List preview
                    listPreviewSection
                    
                    // List details
                    listDetailsSection
                    
                    // Action buttons
                    actionButtonsSection
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .sheet(isPresented: $showingEditView) {
            EditListView(listItem: listItem)
        }
        .sheet(isPresented: $showingExportView) {
            ExportView(listItem: listItem)
        }
        .alert("Delete List", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteList()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this list? This action cannot be undone.")
        }
        .onAppear {
            AnalyticsService.shared.track(.listPreviewViewed, properties: ["list_id": listItem.id.uuidString])
        }
    }
    
    private var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Text("List Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Menu {
                Button {
                    showingEditView = true
                    AnalyticsService.shared.track(.buttonTapped, properties: ["button_name": "edit_list"])
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                    AnalyticsService.shared.track(.buttonTapped, properties: ["button_name": "delete_list"])
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title2)
                    .fontWeight(.medium)
            }
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
    
    private var listPreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preview")
                .font(.headline)
                .fontWeight(.semibold)
            
            ListPreviewView(
                title: listItem.title,
                items: listItem.items,
                designSettings: listItem.designSettings,
                template: ListTemplate(rawValue: listItem.designSettings.templateType) ?? .modern
            )
            .frame(height: 240)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var listDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                DetailRow(label: "Title", value: listItem.title)
                DetailRow(label: "Items", value: "\(listItem.items.count)")
                DetailRow(label: "Template", value: ListTemplate(rawValue: listItem.designSettings.templateType)?.displayName ?? "Modern")
                DetailRow(label: "Created", value: listItem.createdAt.formatted(date: .abbreviated, time: .shortened))
                DetailRow(label: "Updated", value: listItem.updatedAt.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Export button
            Button {
                showingExportView = true
                AnalyticsService.shared.track(.buttonTapped, properties: ["button_name": "export_list"])
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                    Text("Export & Share")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(12)
            }
            
            // Edit button
            Button {
                showingEditView = true
                AnalyticsService.shared.track(.buttonTapped, properties: ["button_name": "edit_from_detail"])
            } label: {
                HStack {
                    Image(systemName: "pencil")
                        .font(.title2)
                    Text("Edit List")
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
        }
    }
    
    private func deleteList() {
        AnalyticsService.shared.track(.listDeleted, properties: ["list_id": listItem.id.uuidString])
        modelContext.delete(listItem)
        dismiss()
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct EditListView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var listItem: ListItem
    
    @State private var editedTitle: String
    @State private var editedItems: [String]
    @State private var currentTemplate: ListTemplate
    @State private var designSettings: DesignSettings
    @State private var showingTemplateSelector = false
    @State private var showingCustomization = false
    
    init(listItem: ListItem) {
        self.listItem = listItem
        self._editedTitle = State(initialValue: listItem.title)
        self._editedItems = State(initialValue: listItem.items + Array(repeating: "", count: max(0, 5 - listItem.items.count)))
        self._currentTemplate = State(initialValue: ListTemplate(rawValue: listItem.designSettings.templateType) ?? .modern)
        self._designSettings = State(initialValue: listItem.designSettings)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
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
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .sheet(isPresented: $showingTemplateSelector) {
            TemplateSelectionView(selectedTemplate: $currentTemplate, designSettings: $designSettings, userTitle: editedTitle, userItems: editedItems)
        }
        .sheet(isPresented: $showingCustomization) {
            CustomizationView(designSettings: $designSettings)
        }
        .onAppear {
            AnalyticsService.shared.trackScreenView("edit_list")
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .font(.body)
            
            Spacer()
            
            Text("Edit List")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("Save") {
                saveChanges()
            }
            .font(.body)
            .fontWeight(.semibold)
            .disabled(editedTitle.isEmpty)
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
        VStack(alignment: .leading, spacing: 12) {
            Text("List Title")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextField("Enter your list title", text: $editedTitle)
                .textFieldStyle(.roundedBorder)
                .font(.body)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var itemsInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("List Items")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { index in
                    HStack {
                        Text("\(index + 1).")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(width: 20, alignment: .leading)
                        
                        TextField("Enter item \(index + 1)", text: $editedItems[index])
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var templatePreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.headline)
                .fontWeight(.semibold)
            
            Button {
                showingTemplateSelector = true
            } label: {
                ListPreviewView(
                    title: editedTitle.isEmpty ? "Your List Title" : editedTitle,
                    items: editedItems.filter { !$0.isEmpty },
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
    
    private func saveChanges() {
        let nonEmptyItems = editedItems.filter { !$0.isEmpty }
        
        listItem.updateTitle(editedTitle)
        listItem.updateItems(nonEmptyItems)
        listItem.updateDesignSettings(designSettings)
        
        AnalyticsService.shared.track(.listEdited, properties: [
            "list_id": listItem.id.uuidString,
            "title_changed": editedTitle != listItem.title,
            "items_changed": nonEmptyItems != listItem.items,
            "template_changed": currentTemplate.rawValue != listItem.designSettings.templateType
        ])
        
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ListItem.self, configurations: config)
    let sampleList = ListItem(
        title: "My Favorite Movies",
        items: ["The Shawshank Redemption", "The Godfather", "Pulp Fiction", "The Dark Knight"],
        designSettings: DesignSettings()
    )
    
    return ListDetailView(listItem: sampleList)
        .modelContainer(container)
} 