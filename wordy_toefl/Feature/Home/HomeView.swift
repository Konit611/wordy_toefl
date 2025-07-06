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
    @Query private var words: [Word]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(words) { word in
                    NavigationLink {
                        WordDetailView(word: word)
                    } label: {
                        WordRowView(word: word)
                    }
                }
                .onDelete(perform: deleteWords)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .navigationTitle("단어 목록")
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addSampleWord) {
                        Label("Add Word", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("단어를 선택하세요")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }

    private func addSampleWord() {
        withAnimation {
            let newWord = Word(
                text: "Sample",
                meaning: "예시",
                partOfSpeech: "noun",
                exampleSentence: "This is a sample sentence.",
                pronunciation: "/ˈsæmpəl/"
            )
            modelContext.insert(newWord)
        }
    }

    private func deleteWords(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(words[index])
            }
        }
    }
}

// MARK: - Word Row View
struct WordRowView: View {
    let word: Word
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(word.text)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if word.isLearned {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            Text(word.meaning)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(word.partOfSpeech)
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Word Detail View
struct WordDetailView: View {
    let word: Word
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 단어 헤더
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(word.text)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: toggleLearned) {
                            Image(systemName: word.isLearned ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(word.isLearned ? .green : .gray)
                        }
                    }
                    
                    Text(word.pronunciation)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text(word.partOfSpeech)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Divider()
                
                // 의미
                VStack(alignment: .leading, spacing: 8) {
                    Text("의미")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(word.meaning)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // 예문
                if !word.exampleSentence.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("예문")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(word.exampleSentence)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // 유의어/반의어
                if !word.synonyms.isEmpty || !word.antonyms.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        if !word.synonyms.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("유의어")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(word.synonyms)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if !word.antonyms.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("반의어")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(word.antonyms)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(word.text)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
    
    private func toggleLearned() {
        withAnimation {
            word.isLearned.toggle()
            word.updatedAt = Date()
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Word.self, inMemory: true)
}
