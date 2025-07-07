//
//  ContentView.swift
//  wordy_toefl
//
//  Created by GEUNIL on 2025/07/06.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HomeViewModel?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 헤더
                    HeaderView()
                    
                    if let viewModel = viewModel {
                        // 총 목표 달성률
                        TotalProgressCard(percentage: viewModel.totalProgressPercentage)
                        
                        // 테스트 대상 단어 & 테스트 하러 가기
                        HStack(spacing: 16) {
                            TestTargetCard(count: viewModel.testTargetWordsCount)
                            TestGoCard()
                        }
                        .padding(.horizontal)
                        
                        // 데일리 단어 섹션
                        DailyWordsSection(dailyWords: viewModel.dailyWords)
                    } else {
                        // 로딩 중
                        ProgressView("데이터 로딩 중...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .background(Color.customBackgroundGreen)
            .onAppear {
                if viewModel == nil {
                    viewModel = HomeViewModel(modelContext: modelContext)
                }
            }
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    var body: some View {
        HStack {
            Image("logo_image")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            Spacer()
            
            NavigationLink(destination: SettingView()) {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(.wordyBlack)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Total Progress Card
struct TotalProgressCard: View {
    let percentage: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("총 목표 달성률")
                .font(.headline)
                .foregroundColor(.customBackgroundGreen)
            
            Text("\(percentage)%")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.customBackgroundGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Color.customGray2)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Test Target Card
struct TestTargetCard: View {
    let count: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("테스트 대상 단어")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.wordyBlack)
            
            Spacer(minLength: 6)
            
            HStack {
                Spacer()
                Text("\(count)개")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.customBackgroundGreen)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 120)
        .padding(20)
        .background(Color.customGray1)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Test Go Card
struct TestGoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("테스트\n하러 가기")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.wordyBlack)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
            
            Spacer(minLength: 6)
            
            HStack {
                Spacer()
                NavigationLink(destination: TestView()) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.customBackgroundGreen)
                        .clipShape(Circle())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 120)
        .padding(20)
        .background(Color.customCoolGray)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Daily Words Section
struct DailyWordsSection: View {
    let dailyWords: [DailyWord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("데일리 단어")
                .font(.headline)
                .foregroundColor(.wordyBlack)
                .padding(.top, 20)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ForEach(Array(dailyWords.prefix(5).enumerated()), id: \.element.id) { index, dailyWord in
                    DailyWordRowView(dailyWord: dailyWord, isFirst: index == 0)
                }
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Daily Word Row View
struct DailyWordRowView: View {
    let dailyWord: DailyWord
    let isFirst: Bool
    
    var body: some View {
        NavigationLink(destination: WordsView()) {
            HStack {
                if isFirst {
                    // 첫 번째 항목의 아이콘
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundColor(.customGray2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(dailyWord.words.first?.text ?? "Include") 포함 \(dailyWord.words.count)개")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(isFirst ? .white : .customBackgroundGreen)
                    
                    Text(formatDate(dailyWord.studyDate))
                        .font(.subheadline)
                        .foregroundColor(isFirst ? .white.opacity(0.8) : .wordyBlack)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.title2)
                    .foregroundColor(isFirst ? .wordyBlack : .wordyWhite)
                    .frame(width: 36, height: 36)
                    .background(isFirst ? .wordyWhite : .wordyBlack)
                    .clipShape(Circle())
            }
            .padding(20)
            .background(isFirst ? Color.customBackgroundGreen : Color.clear)
            .cornerRadius(isFirst ? 16 : 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Word.self, DailyWord.self], inMemory: true)
}
