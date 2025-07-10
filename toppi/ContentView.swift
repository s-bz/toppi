//
//  ContentView.swift
//  toppi
//
//  Created by Samuel Bultez on 10/7/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ListItem.updatedAt, order: .reverse) private var listItems: [ListItem]
    @State private var showingCreateList = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if listItems.isEmpty {
                    EmptyStateView {
                        showingCreateList = true
                        AnalyticsService.shared.track(.buttonTapped, properties: ["button_name": "create_first_list"])
                    }
                } else {
                    ListGridView(listItems: listItems)
                }
            }
            .navigationTitle("My Lists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateList = true
                        AnalyticsService.shared.track(.buttonTapped, properties: ["button_name": "create_new_list"])
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateList) {
            CreateListView()
                .onAppear {
                    AnalyticsService.shared.trackScreenView("create_list")
                }
        }
        .onAppear {
            AnalyticsService.shared.trackScreenView("my_lists")
            AnalyticsService.shared.track(.myListsViewed, properties: ["list_count": listItems.count])
        }
    }
}

struct EmptyStateView: View {
    let onCreateList: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                Text("Create Your First List")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Make beautiful top lists to share with friends and on social media")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button {
                onCreateList()
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Create List")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct ListGridView: View {
    let listItems: [ListItem]
    @Environment(\.modelContext) private var modelContext
    @State private var showingExportView = false
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    @State private var showingActionSheet = false
    @State private var selectedListItem: ListItem?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(listItems) { listItem in
                    ListCardView(listItem: listItem)
                        .onTapGesture {
                            selectedListItem = listItem
                            showingActionSheet = true
                        }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingExportView) {
            if let listItem = selectedListItem {
                ExportView(listItem: listItem)
            }
        }
        .sheet(isPresented: $showingEditView) {
            if let listItem = selectedListItem {
                EditListView(listItem: listItem)
            }
        }
        .confirmationDialog("List Actions", isPresented: $showingActionSheet, presenting: selectedListItem) { listItem in
            Button {
                showingExportView = true
                AnalyticsService.shared.track(.buttonTapped, properties: ["button_name": "share_from_menu"])
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            Button {
                showingEditView = true
                AnalyticsService.shared.track(.buttonTapped, properties: ["button_name": "edit_from_menu"])
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button("Delete", role: .destructive) {
                showingDeleteAlert = true
                AnalyticsService.shared.track(.buttonTapped, properties: ["button_name": "delete_from_menu"])
            }
            
            Button("Cancel", role: .cancel) { }
        } message: { listItem in
            Text("What would you like to do with \"\(listItem.title)\"?")
        }
        .alert("Delete List", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let listItem = selectedListItem {
                    deleteList(listItem)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this list? This action cannot be undone.")
        }
    }
    
    private func deleteList(_ listItem: ListItem) {
        AnalyticsService.shared.track(.listDeleted, properties: ["list_id": listItem.id.uuidString])
        modelContext.delete(listItem)
        selectedListItem = nil
    }
}

struct ListCardView: View {
    let listItem: ListItem
    
    var body: some View {
        ListPreviewView(
            title: listItem.title,
            items: listItem.items,
            designSettings: listItem.designSettings,
            template: ListTemplate(rawValue: listItem.designSettings.templateType) ?? .modern,
            showTitle: true
        )
        .frame(height: 240)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ListItem.self, inMemory: true)
}
