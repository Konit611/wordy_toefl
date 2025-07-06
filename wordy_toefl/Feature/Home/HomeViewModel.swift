//
//  HomeViewModel.swift
//  wordy_toefl
//
//  Created by GEUNIL on 2025/07/06.
//

import Foundation
import SwiftData

@Observable
class HomeViewModel {
    private var modelContext: ModelContext
    
    // 총 목표 달성률
    var totalProgressPercentage: Int = 0
    
    // 테스트 대상 단어 개수
    var testTargetWordsCount: Int = 0
    
    // 데일리 단어 목록
    var dailyWords: [DailyWord] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadData()
    }
    
    func loadData() {
        calculateTotalProgress()
        calculateTestTargetWords()
        loadDailyWords()
    }
    
    private func calculateTotalProgress() {
        // 전체 Word 수
        let totalWordsDescriptor = FetchDescriptor<Word>()
        let totalWords = (try? modelContext.fetch(totalWordsDescriptor)) ?? []
        
        // DailyWord 중 isLearned가 true인 Word 수
        let dailyWordsDescriptor = FetchDescriptor<DailyWord>()
        let dailyWords = (try? modelContext.fetch(dailyWordsDescriptor)) ?? []
        
        let learnedWordsCount = dailyWords.reduce(0) { count, dailyWord in
            count + dailyWord.words.filter { $0.isLearned }.count
        }
        
        if totalWords.count > 0 {
            totalProgressPercentage = Int((Double(learnedWordsCount) / Double(totalWords.count)) * 100)
        } else {
            totalProgressPercentage = 0
        }
    }
    
    private func calculateTestTargetWords() {
        // DailyWord의 review1, review2, review3이 nil이 아닌 것들의 word 개수
        let descriptor = FetchDescriptor<DailyWord>()
        let allDailyWords = (try? modelContext.fetch(descriptor)) ?? []
        
        testTargetWordsCount = allDailyWords.filter { dailyWord in
            dailyWord.review1Date != nil || dailyWord.review2Date != nil || dailyWord.review3Date != nil
        }.reduce(0) { count, dailyWord in
            count + dailyWord.words.count
        }
    }
    
    private func loadDailyWords() {
        let descriptor = FetchDescriptor<DailyWord>()
        let allDailyWords = (try? modelContext.fetch(descriptor)) ?? []
        
        let calendar = Calendar.current
        let today = Date()
        
        // StudyDate가 오늘인 것들 (FirstDay가 nil이라고 했지만, 오늘 날짜를 의미하는 것으로 해석)
        let todayWords = allDailyWords.filter { dailyWord in
            calendar.isDate(dailyWord.studyDate, inSameDayAs: today)
        }
        
        // isLearned가 false인 것들 중 review1, 2, 3이 가장 가까운 순으로 정렬
        let reviewWords = allDailyWords.filter { dailyWord in
            dailyWord.words.contains { !$0.isLearned }
        }.sorted { dailyWord1, dailyWord2 in
            let nearestDate1 = getNearestReviewDate(for: dailyWord1)
            let nearestDate2 = getNearestReviewDate(for: dailyWord2)
            
            if let date1 = nearestDate1, let date2 = nearestDate2 {
                return date1 < date2
            } else if nearestDate1 != nil {
                return true
            } else {
                return false
            }
        }
        
        dailyWords = todayWords + reviewWords
    }
    
    private func getNearestReviewDate(for dailyWord: DailyWord) -> Date? {
        let dates = [dailyWord.review1Date, dailyWord.review2Date, dailyWord.review3Date]
            .compactMap { $0 }
        
        return dates.min { $0 < $1 }
    }
}

