import SwiftUI
import SwiftData

enum WordTab: CaseIterable, Equatable {
    case definition, usage, synonyms, antonyms
    
    var title: String {
        switch self {
        case .definition: return "Definition"
        case .usage: return "Usage"
        case .synonyms: return "Synonyms"
        case .antonyms: return "Antonyms"
        }
    }
}

struct WordsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var words: [Word]
    
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var showingEndAlert = false
    @State private var selectedTab: WordTab = .definition
    
    var currentWord: Word? {
        guard !words.isEmpty && currentIndex < words.count else { return nil }
        return words[currentIndex]
    }
    
    var isCompleted: Bool {
        return currentIndex >= words.count
    }
    
    var isLastWord: Bool {
        return currentIndex == words.count - 1
    }
    
    var backgroundColor: Color {
        if isCompleted {
            return .wordyYellow
        } else if isFlipped {
            return .wordyBlack
        } else {
            return currentIndex == 0 ? .wordyGreen : .wordyYellow
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // 상단 버튼들
                    HStack {
                        if !isFlipped {
                            Button("End") {
                                showingEndAlert = true
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.clear)
                            .foregroundColor(.wordyRed)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.wordyRed, lineWidth: 1)
                            )
                            .contentShape(Rectangle())
                        }
                        
                        Spacer()
                        
                        if !isCompleted {
                            Button("Flip →") {
                                isFlipped.toggle()
                                selectedTab = .definition // 플립할 때마다 첫 번째 탭으로 리셋
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.clear)
                            .foregroundColor(isFlipped ? .white : .wordyBlack)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isFlipped ? Color.white : Color.wordyBlack, lineWidth: 1)
                            )
                            .contentShape(Rectangle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // 단어 카드 또는 완료 화면
                    if isCompleted {
                        // 완료 화면
                        VStack(spacing: 30) {
                            Text("학습 완료!")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.wordyBlack)
                            
                            Text("모든 단어를 학습하셨습니다.")
                                .font(.system(size: 18))
                                .foregroundColor(.wordyBlack)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 40)
                    } else if let word = currentWord {
                        WordCardView(
                            word: word,
                            isFlipped: isFlipped,
                            backgroundColor: backgroundColor,
                            selectedTab: selectedTab,
                            onTabChanged: { tab in
                                selectedTab = tab
                            }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 40)
                    }
                    
                    // 하단 네비게이션 버튼들
                    if !isFlipped {
                        HStack(spacing: 20) {
                            if isCompleted {
                                // 완료 화면에서는 Before 버튼만 전체 너비
                                Button("← Before") {
                                    goToPreviousWord()
                                }
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity)
                                .background(Color.clear)
                                .foregroundColor(.wordyBlack)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.wordyBlack, lineWidth: 1)
                                )
                                .contentShape(Rectangle())
                            } else if currentIndex == 0 {
                                // 첫 번째 단어일 때 Next만 전체 너비
                                if currentIndex < words.count - 1 {
                                    Button("Next →") {
                                        goToNextWord()
                                    }
                                    .padding(.vertical, 15)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.clear)
                                    .foregroundColor(.wordyBlack)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.wordyBlack, lineWidth: 1)
                                    )
                                    .contentShape(Rectangle())
                                }
                            } else {
                                // 두 번째부터는 Before와 Next가 반반
                                Button("← Before") {
                                    goToPreviousWord()
                                }
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity)
                                .background(Color.clear)
                                .foregroundColor(.wordyBlack)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.wordyBlack, lineWidth: 1)
                                )
                                .contentShape(Rectangle())
                                
                                Button("Next →") {
                                    goToNextWord()
                                }
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity)
                                .background(Color.clear)
                                .foregroundColor(.wordyBlack)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.wordyBlack, lineWidth: 1)
                                )
                                .contentShape(Rectangle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
                .background(backgroundColor.ignoresSafeArea())
            }
        }
        .navigationBarHidden(true)
        .alert(isLastWord ? "학습 완료" : "학습을 종료하시겠습니까?", isPresented: $showingEndAlert) {
            Button("확인") {
                dismiss()
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text(isLastWord ? "학습을 종료하고 홈으로 돌아가시겠습니까?" : "도중에 마쳤음으로 완료로 표시되지 않습니다.")
        }
    }
    
    private func goToNextWord() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentIndex += 1
            isFlipped = false
            selectedTab = .definition
        }
    }
    
    private func goToPreviousWord() {
        if currentIndex > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex -= 1
                isFlipped = false
                selectedTab = .definition
            }
        }
    }
}

// MARK: - Word Card View
struct WordCardView: View {
    let word: Word
    let isFlipped: Bool
    let backgroundColor: Color
    let selectedTab: WordTab
    let onTabChanged: (WordTab) -> Void
    
    var body: some View {
        if !isFlipped {
            // 앞면 - 단어와 발음기호
            VStack(spacing: 20) {
                Text(word.text)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.wordyBlack)
                
                Text(word.pronunciation)
                    .font(.system(size: 24))
                    .foregroundColor(.wordyBlack)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // 뒷면 - 의미, 예문, 유의어, 반의어
            VStack(alignment: .leading, spacing: 0) {
                // 상단 단어와 발음
                VStack(alignment: .leading, spacing: 8) {
                    Text(word.text)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(word.pronunciation)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                
                // 탭 버튼들 (가로 스크롤)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(WordTab.allCases, id: \.self) { tab in
                            TabButton(
                                title: tab.title,
                                isSelected: selectedTab == tab
                            ) {
                                onTabChanged(tab)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.top, 20)
                
                // 선택된 탭에 따른 내용 (세로 스크롤)
                ScrollView(.vertical, showsIndicators: false) {
                    Text(getContentForSelectedTab())
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func getContentForSelectedTab() -> String {
        switch selectedTab {
        case .definition:
            if word.meaning.isEmpty {
                return "의미 정보가 없습니다."
            } else {
                return word.meaning
            }
        case .usage:
            if word.exampleSentence.isEmpty {
                return "예문이 없습니다."
            } else {
                return word.exampleSentence
            }
        case .synonyms:
            if word.synonyms.isEmpty {
                return "유의어 정보가 없습니다."
            } else {
                // 여러 유의어가 쉼표로 구분되어 있을 경우 줄바꿈으로 표시
                let synonymsArray = word.synonyms.components(separatedBy: ",")
                return synonymsArray.map { "• \($0.trimmingCharacters(in: .whitespaces))" }.joined(separator: "\n")
            }
        case .antonyms:
            if word.antonyms.isEmpty {
                return "반의어 정보가 없습니다."
            } else {
                // 여러 반의어가 쉼표로 구분되어 있을 경우 줄바꿈으로 표시
                let antonymsArray = word.antonyms.components(separatedBy: ",")
                return antonymsArray.map { "• \($0.trimmingCharacters(in: .whitespaces))" }.joined(separator: "\n")
            }
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .wordyBlack : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.white : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 1)
                )
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    WordsView()
        .modelContainer(for: Word.self, inMemory: true)
} 
