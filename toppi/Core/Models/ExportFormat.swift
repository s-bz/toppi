import Foundation
import SwiftUI

enum ExportFormat: String, CaseIterable {
    case instagramPost = "instagram-post"
    case instagramStory = "instagram-story"
    case tiktok = "tiktok"
    case twitter = "twitter"
    case generalSocial = "general-social"
    
    var displayName: String {
        switch self {
        case .instagramPost:
            return "Instagram Post"
        case .instagramStory:
            return "Instagram Story"
        case .tiktok:
            return "TikTok"
        case .twitter:
            return "Twitter/X"
        case .generalSocial:
            return "General Social"
        }
    }
    
    var size: CGSize {
        switch self {
        case .instagramPost, .generalSocial:
            return CGSize(width: 1080, height: 1080)
        case .instagramStory, .tiktok:
            return CGSize(width: 1080, height: 1920)
        case .twitter:
            return CGSize(width: 1200, height: 675)
        }
    }
    
    var aspectRatio: Double {
        return size.width / size.height
    }
    
    var icon: String {
        switch self {
        case .instagramPost:
            return "square"
        case .instagramStory, .tiktok:
            return "rectangle.portrait"
        case .twitter:
            return "rectangle"
        case .generalSocial:
            return "square.grid.2x2"
        }
    }
}

struct ExportSettings {
    let format: ExportFormat
    let quality: Double
    let includeWatermark: Bool
    
    init(format: ExportFormat = .instagramPost, quality: Double = 0.9, includeWatermark: Bool = false) {
        self.format = format
        self.quality = quality
        self.includeWatermark = includeWatermark
    }
} 