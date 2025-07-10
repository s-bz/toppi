import Foundation
import SwiftUI

class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    private init() {}
    
    // Track key events throughout the app
    func track(_ event: AnalyticsEvent, properties: [String: Any] = [:]) {
        // TODO: Integrate with PostHog SDK
        // For now, just log events for development
        print("Analytics Event: \(event.rawValue)")
        if !properties.isEmpty {
            print("Properties: \(properties)")
        }
    }
    
    // Track screen views
    func trackScreenView(_ screenName: String, properties: [String: Any] = [:]) {
        var eventProperties = properties
        eventProperties["screen_name"] = screenName
        track(.screenView, properties: eventProperties)
    }
    
    // Track user actions
    func trackUserAction(_ action: String, properties: [String: Any] = [:]) {
        var eventProperties = properties
        eventProperties["action"] = action
        track(.userAction, properties: eventProperties)
    }
}

enum AnalyticsEvent: String, CaseIterable {
    // App lifecycle
    case appLaunched = "app_launched"
    case appBackgrounded = "app_backgrounded"
    case appForegrounded = "app_foregrounded"
    
    // Screen views
    case screenView = "screen_view"
    
    // List creation
    case listCreated = "list_created"
    case listEdited = "list_edited"
    case listDeleted = "list_deleted"
    case listTitleChanged = "list_title_changed"
    case listItemAdded = "list_item_added"
    case listItemRemoved = "list_item_removed"
    case listItemEdited = "list_item_edited"
    
    // Template selection
    case templateSelected = "template_selected"
    case templatePreviewViewed = "template_preview_viewed"
    
    // Background customization
    case backgroundImageSelected = "background_image_selected"
    case backgroundImageUploaded = "background_image_uploaded"
    case backgroundColorChanged = "background_color_changed"
    case gradientApplied = "gradient_applied"
    
    // Stickers
    case stickerAdded = "sticker_added"
    case stickerRemoved = "sticker_removed"
    case stickerMoved = "sticker_moved"
    case stickerResized = "sticker_resized"
    
    // Export and sharing
    case exportFormatSelected = "export_format_selected"
    case listExported = "list_exported"
    case shareButtonTapped = "share_button_tapped"
    case shareCompleted = "share_completed"
    case shareToInstagram = "share_to_instagram"
    case shareToTikTok = "share_to_tiktok"
    case shareToTwitter = "share_to_twitter"
    case saveToPhotos = "save_to_photos"
    
    // User actions
    case userAction = "user_action"
    case buttonTapped = "button_tapped"
    
    // Onboarding
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"
    case onboardingSkipped = "onboarding_skipped"
    
    // List management
    case myListsViewed = "my_lists_viewed"
    case listOpened = "list_opened"
    case listPreviewViewed = "list_preview_viewed"
}

// Extension to easily track button taps
extension View {
    func trackButtonTap(_ buttonName: String, properties: [String: Any] = [:]) -> some View {
        self.onTapGesture {
            var eventProperties = properties
            eventProperties["button_name"] = buttonName
            AnalyticsService.shared.track(.buttonTapped, properties: eventProperties)
        }
    }
} 