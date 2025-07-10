import Foundation
import SwiftData

@Model
final class ListItem {
    var id: UUID
    var title: String
    var items: [String]
    var designSettings: DesignSettings
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, items: [String] = [], designSettings: DesignSettings = DesignSettings()) {
        self.id = UUID()
        self.title = title
        self.items = items
        self.designSettings = designSettings
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func updateItems(_ newItems: [String]) {
        self.items = Array(newItems.prefix(5)) // Limit to 5 items
        self.updatedAt = Date()
    }
    
    func updateTitle(_ newTitle: String) {
        self.title = newTitle
        self.updatedAt = Date()
    }
    
    func updateDesignSettings(_ newDesignSettings: DesignSettings) {
        self.designSettings = newDesignSettings
        self.updatedAt = Date()
    }
} 