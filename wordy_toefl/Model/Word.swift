//
//  Word.swift
//  wordy_toefl
//
//  Created by GEUNIL on 2025/07/06.
//

import Foundation
import SwiftData

// MARK: - Word Model
@Model
final class Word {
    var id: UUID
    var text: String
    var meaning: String
    var partOfSpeech: String
    var exampleSentence: String
    var pronunciation: String
    var synonyms: String
    var antonyms: String
    var isLearned: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        text: String,
        meaning: String,
        partOfSpeech: String,
        exampleSentence: String,
        pronunciation: String,
        synonyms: String = "",
        antonyms: String = "",
        isLearned: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.meaning = meaning
        self.partOfSpeech = partOfSpeech
        self.exampleSentence = exampleSentence
        self.pronunciation = pronunciation
        self.synonyms = synonyms
        self.antonyms = antonyms
        self.isLearned = isLearned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
