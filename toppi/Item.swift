//
//  Item.swift
//  toppi
//
//  Created by Samuel Bultez on 10/7/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
