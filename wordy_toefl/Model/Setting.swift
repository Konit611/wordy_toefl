//
//  Setting.swift
//  wordy_toefl
//
//  Created by GEUNIL on 2025/07/06.
//

import Foundation
import SwiftData

// MARK: - Setting Model
@Model
final class Setting {
    var dailyWordLimit: Int
    var learningLanguage: String
    var createdAt: Date
    var updatedAt: Date

    init(
        dailyWordLimit: Int = 30,
        learningLanguage: String = "en",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.dailyWordLimit = dailyWordLimit
        self.learningLanguage = learningLanguage
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
