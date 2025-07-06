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
    var id: UUID // SwiftData가 자동으로 생성하지만, 명시적 관리를 위해 유지
    var text: String // 단어 자체 (예: "abandon")
    var meaning: String // 단어의 의미
    var partOfSpeech: String // 품사 (예: "명사", "동사", "형용사" 등)
    var exampleSentence: String // 예시 문장
    var pronunciation: String // 발음 기호 (예: IPA 표기, 또는 한글/한자 발음)
    var synonyms: String // 유의어 (쉼표로 구분된 문자열)
    var antonyms: String // 반의어 (쉼표로 구분된 문자열)
    var isLearned: Bool // 학습 완료 여부
    
    // 테스트용 필드 추가
    var meaningTestEn: String // 영어 의미 테스트 선택지 (쉼표 구분)
    var meaningTestKo: String // 한국어 의미 테스트 선택지 (쉼표 구분)
    var meaningTestZh: String // 중국어 의미 테스트 선택지 (쉼표 구분)
    var meaningTestJa: String // 일본어 의미 테스트 선택지 (쉼표 구분)
    var synonymTestEn: String // 영어 유의어 테스트 선택지 (쉼표 구분)
    var antonymTestEn: String // 영어 반의어 테스트 선택지 (쉼표 구분)

    var createdAt: Date // 단어 추가 날짜
    var updatedAt: Date // 단어 정보 갱신 날짜

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
        meaningTestEn: String = "",
        meaningTestKo: String = "",
        meaningTestZh: String = "",
        meaningTestJa: String = "",
        synonymTestEn: String = "",
        antonymTestEn: String = "",
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
        self.meaningTestEn = meaningTestEn
        self.meaningTestKo = meaningTestKo
        self.meaningTestZh = meaningTestZh
        self.meaningTestJa = meaningTestJa
        self.synonymTestEn = synonymTestEn
        self.antonymTestEn = antonymTestEn
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
