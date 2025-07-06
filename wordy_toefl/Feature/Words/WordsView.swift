import SwiftUI
import SwiftData

struct WordsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var words: [Word]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("단어 학습")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.customBlack)
                    
                    if words.isEmpty {
                        EmptyWordsView()
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(words) { word in
                                WordCardView(word: word)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color.customBackgroundGreen)
        }
    }
}

struct WordCardView: View {
    let word: Word
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(word.text)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.customBackgroundGreen)
                    
                    Text(word.pronunciation)
                        .font(.subheadline)
                        .foregroundColor(.customBlack)
                }
                
                Spacer()
                
                Button(action: {
                    toggleLearned()
                }) {
                    Image(systemName: word.isLearned ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(word.isLearned ? .customCoolGray : .customBlack)
                }
            }
            
            Text(word.meaning)
                .font(.body)
                .foregroundColor(.customBlack)
            
            if !word.exampleSentence.isEmpty {
                Text(word.exampleSentence)
                    .font(.caption)
                    .foregroundColor(.customBlack)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
    }
    
    private func toggleLearned() {
        withAnimation {
            word.isLearned.toggle()
            word.updatedAt = Date()
        }
    }
}

struct EmptyWordsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.customBlack)
            
            Text("학습할 단어가 없습니다")
                .font(.headline)
                .foregroundColor(.customBlack)
            
            Text("데이터를 초기화하거나 새로운 단어를 추가해보세요")
                .font(.subheadline)
                .foregroundColor(.customBlack)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    WordsView()
        .modelContainer(for: Word.self, inMemory: true)
} 