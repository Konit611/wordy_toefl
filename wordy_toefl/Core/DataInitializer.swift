//
//  DataInitializer.swift
//  wordy_toefl
//
//  Created by GEUNIL on 2025/07/06.
//

import Foundation
import SwiftData

class DataInitializer {
    static let shared = DataInitializer()
    private init() {}
    
    /// 앱 시작 시 데이터 초기화
    func initializeDataIfNeeded(context: ModelContext) {
        initializeWordsIfNeeded(context: context)
        initializeSettingsIfNeeded(context: context)
        initializeDailyWordsIfNeeded(context: context)
    }
    
    /// CSV 파일에서 단어 데이터를 초기화
    private func initializeWordsIfNeeded(context: ModelContext) {
        // 기존 단어가 있는지 확인
        let fetchDescriptor = FetchDescriptor<Word>()
        do {
            let existingWords = try context.fetch(fetchDescriptor)
            if !existingWords.isEmpty {
                print("Words already exist in database: \(existingWords.count)")
                return
            }
        } catch {
            print("Error fetching existing words: \(error)")
            return
        }
        
        // CSV 파일에서 단어 데이터 로드
        guard let csvData = loadWordsFromCSV() else {
            print("Failed to load words from CSV")
            return
        }
        
        // 단어 데이터를 SwiftData에 저장
        for wordData in csvData {
            let word = Word(
                text: wordData.text,
                meaning: wordData.meaning,
                partOfSpeech: wordData.partOfSpeech,
                exampleSentence: wordData.exampleSentence,
                pronunciation: wordData.pronunciation,
                synonyms: wordData.synonyms,
                antonyms: wordData.antonyms,
                isLearned: wordData.isLearned,
                meaningTestEn: wordData.meaningTestEn,
                meaningTestKo: wordData.meaningTestKo,
                meaningTestZh: wordData.meaningTestZh,
                meaningTestJa: wordData.meaningTestJa,
                synonymTestEn: wordData.synonymTestEn,
                antonymTestEn: wordData.antonymTestEn
            )
            context.insert(word)
        }
        
        // 저장
        do {
            try context.save()
            print("Successfully initialized \(csvData.count) words from CSV")
        } catch {
            print("Error saving words to database: \(error)")
        }
    }
    
    /// 설정 기본값 초기화
    private func initializeSettingsIfNeeded(context: ModelContext) {
        // 기존 설정이 있는지 확인
        let fetchDescriptor = FetchDescriptor<Setting>()
        do {
            let existingSettings = try context.fetch(fetchDescriptor)
            if !existingSettings.isEmpty {
                print("Settings already exist in database")
                return
            }
        } catch {
            print("Error fetching existing settings: \(error)")
            return
        }
        
        // 기본 설정 생성
        let defaultSettings = Setting(
            dailyWordLimit: 30,
            learningLanguage: "en"
        )
        
        context.insert(defaultSettings)
        
        // 저장
        do {
            try context.save()
            print("Successfully initialized default settings")
        } catch {
            print("Error saving settings to database: \(error)")
        }
    }
    
    /// DailyWords 초기화
    private func initializeDailyWordsIfNeeded(context: ModelContext) {
        // 기존 DailyWord가 있는지 확인
        let fetchDescriptor = FetchDescriptor<DailyWord>()
        do {
            let existingDailyWords = try context.fetch(fetchDescriptor)
            if !existingDailyWords.isEmpty {
                print("DailyWords already exist in database")
                return
            }
        } catch {
            print("Error fetching existing daily words: \(error)")
            return
        }
        
        // 첫 번째 DailyWord 생성 (오늘 날짜로)
        let todayDailyWord = DailyWord(
            studyDate: Date()
        )
        
        context.insert(todayDailyWord)
        
        // 저장
        do {
            try context.save()
            print("Successfully initialized daily words")
        } catch {
            print("Error saving daily words to database: \(error)")
        }
    }
    
    /// CSV 파일에서 단어 데이터 로드
    private func loadWordsFromCSV() -> [WordData]? {
        guard let path = Bundle.main.path(forResource: "words", ofType: "csv") else {
            print("CSV file not found")
            return nil
        }
        
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            var words: [WordData] = []
            
            // 첫 번째 라인은 헤더이므로 건너뛰기
            for line in lines.dropFirst() {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedLine.isEmpty {
                    if let wordData = parseCSVLine(line: trimmedLine) {
                        words.append(wordData)
                    }
                }
            }
            
            return words
        } catch {
            print("Error reading CSV file: \(error)")
            return nil
        }
    }
    
    /// CSV 라인을 파싱하여 WordData 생성 (정교한 파싱)
    private func parseCSVLine(line: String) -> WordData? {
        let components = parseCSVRow(line)
        
        guard components.count >= 14 else {
            print("Invalid CSV line format (expected 14 fields, got \(components.count)): \(line)")
            return nil
        }
        
        // 디버깅: 첫 번째 단어의 경우 모든 컬럼을 출력
        if components.count > 0 && components[0] == "Abate" {
            print("🔍 CSV 파싱 디버깅 - Abate:")
            for (index, component) in components.enumerated() {
                print("  [\(index)]: \(component)")
            }
        }
        
        // CSV 필드 파싱 (CSV 헤더 순서에 맞춤)
        // text,meaning,partOfSpeech,exampleSentence,pronunciation,synonyms,antonyms,isLearned,meaning_test_en,meaning_test_ko,meaning_test_zh,meaning_test_ja,synonym_test_en,antonym_test_en
        let text = components[0]
        let meaning = components[1]
        let partOfSpeech = components[2]
        let exampleSentence = components[3]
        let pronunciation = components[4]
        let synonyms = components[5]
        let antonyms = components[6]
        let isLearned = components[7].lowercased() == "true"
        
        // 테스트 선택지들은 파이프(|)로 구분되어 있음
        let meaningTestEn = components[8]
        let meaningTestKo = components[9]
        let meaningTestZh = components[10]
        let meaningTestJa = components[11]
        let synonymTestEn = components[12]
        let antonymTestEn = components[13]
        
        // Affable 디버깅 (파이프 분리 확인)
        if text == "Affable" {
            print("🔍 Affable 파싱 결과:")
            print("  synonymTestEn: \(synonymTestEn)")
            print("  antonymTestEn: \(antonymTestEn)")
            print("  meaningTestEn: \(meaningTestEn)")
            print("  meaningTestKo: \(meaningTestKo)")
            print("  meaningTestZh: \(meaningTestZh)")
            print("  meaningTestJa: \(meaningTestJa)")
        }
        
        return WordData(
            text: text,
            meaning: meaning,
            partOfSpeech: partOfSpeech,
            exampleSentence: exampleSentence,
            pronunciation: pronunciation,
            synonyms: synonyms,
            antonyms: antonyms,
            isLearned: isLearned,
            meaningTestEn: meaningTestEn,
            meaningTestKo: meaningTestKo,
            meaningTestZh: meaningTestZh,
            meaningTestJa: meaningTestJa,
            synonymTestEn: synonymTestEn,
            antonymTestEn: antonymTestEn
        )
    }
    
    /// CSV 행을 정확하게 파싱 (따옴표와 쉼표 처리)
    private func parseCSVRow(_ row: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false
        var i = row.startIndex
        
        while i < row.endIndex {
            let char = row[i]
            
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                fields.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
                currentField = ""
            } else {
                currentField += String(char)
            }
            
            i = row.index(after: i)
        }
        
        // 마지막 필드 추가
        fields.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
        
        return fields
    }
}

// MARK: - WordData 구조체
struct WordData {
    let text: String
    let meaning: String
    let partOfSpeech: String
    let exampleSentence: String
    let pronunciation: String
    let synonyms: String
    let antonyms: String
    let isLearned: Bool
    let meaningTestEn: String
    let meaningTestKo: String
    let meaningTestZh: String
    let meaningTestJa: String
    let synonymTestEn: String
    let antonymTestEn: String
} 