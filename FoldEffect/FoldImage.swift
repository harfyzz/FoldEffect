//
//  FoldImage.swift
//  FoldEffect
//
//  Created by Afeez Yunus on 03/04/2025.
//

import Foundation
import SwiftData

@Model
final class FoldImage: Identifiable {
    var id: UUID = UUID()
    var image: Int
    var name: String
    var height: CGFloat
    var isFolded: Bool = false
    
    init(image: Int, name: String, height: CGFloat) {
        self.image = image
        self.name = name
        self.height = height
    }
    
}
