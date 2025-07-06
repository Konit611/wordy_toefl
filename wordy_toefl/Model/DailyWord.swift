//
//  DailyWords.swift
//  wordy_toefl
//
//  Created by GEUNIL on 2025/07/06.
//

import Foundation
import SwiftData

// MARK: - DailyWord Model
@Model
final class DailyWord {
    var id: UUID
    var studyDate: Date
    var review1Date: Date?
    var review2Date: Date?
    var review3Date: Date?
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship var words: [Word]

    init(
        id: UUID = UUID(),
        studyDate: Date = Date(),
        review1Date: Date? = nil,
        review2Date: Date? = nil,
        review3Date: Date? = nil,
        isCompleted: Bool = false,
        words: [Word] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.studyDate = studyDate
        self.review1Date = review1Date
        self.review2Date = review2Date
        self.review3Date = review3Date
        self.isCompleted = isCompleted
        self.words = words
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
