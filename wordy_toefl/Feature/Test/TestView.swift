import SwiftUI
import SwiftData

enum QuestionType: CaseIterable {
    case meaning
    case synonym
    case antonym
    
    var title: String {
        switch self {
        case .meaning:
            return "What is the meaning of the word ?"
        case .synonym:
            return "What is the synonyms of the word ?"
        case .antonym:
            return "What is the antonyms of the word ?"
        }
    }
}

struct QuizQuestion {
    let word: Word
    let type: QuestionType
    let options: [String]
    let correctAnswer: String
}

@Observable
class QuizViewModel {
    var currentQuestionIndex = 0
    var score = 0
    var selectedAnswer: String?
    var questions: [QuizQuestion] = []
    var isCompleted = false
    
    init() {
        // 테스트 완료 여부 초기화
        isCompleted = false
    }
    
    func generateQuestions(from words: [Word], setting: Setting?) {
        let testWords = Array(words.prefix(3)) // 3단어만 선택
        questions = testWords.map { word in
            let questionType = QuestionType.allCases.randomElement() ?? .meaning
            
            let (options, correctAnswer) = generateOptions(for: word, type: questionType, setting: setting, allWords: words)
            
            return QuizQuestion(
                word: word,
                type: questionType,
                options: options,
                correctAnswer: correctAnswer
            )
        }
        
        // 상태 초기화
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        isCompleted = false
    }
    
    private func generateOptions(for word: Word, type: QuestionType, setting: Setting?, allWords: [Word]) -> ([String], String) {
        var options: [String] = []
        var correctAnswer: String = ""
        
        switch type {
        case .meaning:
            // 언어에 따라 다른 선택지 사용
            let language = setting?.learningLanguage ?? "en"
            
            switch language {
            case "ko":
                options = word.meaningTestKo.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                correctAnswer = options.first ?? ""
            case "zh":
                options = word.meaningTestZh.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                correctAnswer = options.first ?? ""
            case "ja":
                options = word.meaningTestJa.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                correctAnswer = options.first ?? ""
            default: // "en"
                options = word.meaningTestEn.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                correctAnswer = options.first ?? ""
            }
            
        case .synonym:
            // 유의어 테스트는 항상 영어로만 진행
            options = word.synonymTestEn.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
            correctAnswer = options.first ?? ""
            
            // 4개까지 채우기 위해 다른 단어들의 영어 유의어 추가
            if options.count < 4 {
                let otherWords = allWords.filter { $0.id != word.id }
                for otherWord in otherWords {
                    let otherSynonyms = otherWord.synonymTestEn.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                    // 중복 제거하면서 추가
                    for synonym in otherSynonyms {
                        if !synonym.isEmpty && !options.contains(synonym) && options.count < 4 {
                            options.append(synonym)
                        }
                    }
                    if options.count >= 4 { break }
                }
            }
            
        case .antonym:
            // 반의어 테스트는 항상 영어로만 진행
            options = word.antonymTestEn.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
            correctAnswer = options.first ?? ""
            
            // 4개까지 채우기 위해 다른 단어들의 영어 반의어 추가
            if options.count < 4 {
                let otherWords = allWords.filter { $0.id != word.id }
                for otherWord in otherWords {
                    let otherAntonyms = otherWord.antonymTestEn.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                    // 중복 제거하면서 추가
                    for antonym in otherAntonyms {
                        if !antonym.isEmpty && !options.contains(antonym) && options.count < 4 {
                            options.append(antonym)
                        }
                    }
                    if options.count >= 4 { break }
                }
            }
        }
        
        // 선택지 개수 확인 및 조정
        if options.count < 4 {
            // 부족한 선택지를 다른 단어들에서 보충
            let otherWords = allWords.filter { $0.id != word.id }
            for otherWord in otherWords {
                if options.count >= 4 { break }
                switch type {
                case .meaning:
                    let language = setting?.learningLanguage ?? "en"
                    let otherOptions: [String]
                    switch language {
                    case "ko":
                        otherOptions = otherWord.meaningTestKo.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                    case "zh":
                        otherOptions = otherWord.meaningTestZh.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                    case "ja":
                        otherOptions = otherWord.meaningTestJa.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                    default:
                        otherOptions = otherWord.meaningTestEn.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                    }
                    for option in otherOptions {
                        if !option.isEmpty && !options.contains(option) && options.count < 4 {
                            options.append(option)
                        }
                    }
                case .synonym:
                    let otherSynonyms = otherWord.synonymTestEn.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                    for synonym in otherSynonyms {
                        if !synonym.isEmpty && !options.contains(synonym) && options.count < 4 {
                            options.append(synonym)
                        }
                    }
                case .antonym:
                    let otherAntonyms = otherWord.antonymTestEn.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                    for antonym in otherAntonyms {
                        if !antonym.isEmpty && !options.contains(antonym) && options.count < 4 {
                            options.append(antonym)
                        }
                    }
                }
            }
        }
        
        // 정답이 선택지에 포함되어 있는지 확인
        if !options.contains(correctAnswer) && !correctAnswer.isEmpty {
            // 정답이 선택지에 없다면, 첫 번째 선택지로 대체
            if !options.isEmpty {
                options[0] = correctAnswer
            } else {
                options.append(correctAnswer)
            }
        }
        
        // 선택지 섞기
        options.shuffle()
        
        return (options, correctAnswer)
    }
    
    func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        
        if answer == questions[currentQuestionIndex].correctAnswer {
            score += 1
        }
    }
    
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
        } else {
            isCompleted = true
        }
    }
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Float {
        guard !questions.isEmpty else { return 0 }
        return Float(currentQuestionIndex + 1) / Float(questions.count)
    }
}

struct TestView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var words: [Word]
    @Query private var settings: [Setting]
    
    @State private var quizViewModel = QuizViewModel()
    @State private var showingEndAlert = false
    
    var currentSetting: Setting? {
        return settings.first
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if quizViewModel.isCompleted {
                    // 결과 화면
                    QuizResultView(
                        score: quizViewModel.score,
                        totalQuestions: quizViewModel.questions.count,
                        onRestart: {
                            quizViewModel.generateQuestions(from: words, setting: currentSetting)
                        },
                        onClose: {
                            dismiss()
                        }
                    )
                } else if let currentQuestion = quizViewModel.currentQuestion {
                    // 문제 화면
                    VStack(spacing: 20) {
                        // 상단 End 버튼
                        HStack {
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
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // 진행률 표시
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("\(quizViewModel.currentQuestionIndex + 1)/\(quizViewModel.questions.count)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.wordyBlack)
                            
                            ProgressView(value: quizViewModel.progress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                                .tint(.wordyBlack)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(.horizontal, 20)
                        
                        // 문제 영역
                        VStack(spacing: 30) {
                            VStack(spacing: 20) {
                                Text(currentQuestion.type.title)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.wordyBlack)
                                
                                Text(currentQuestion.word.text)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.wordyBlack)
                            }
                            
                            // 선택지들
                            VStack(spacing: 16) {
                                ForEach(currentQuestion.options, id: \.self) { option in
                                    Button(action: {
                                        quizViewModel.selectAnswer(option)
                                    }) {
                                        Text(option)
                                            .font(.system(size: 16, weight: .medium))
                                            .padding(.vertical, 20)
                                            .padding(.horizontal, 20)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .fill(quizViewModel.selectedAnswer == option ? 
                                                        Color.wordyBlack : Color.clear)
                                            )
                                            .foregroundColor(
                                                quizViewModel.selectedAnswer == option ? 
                                                .white : .wordyBlack
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .stroke(Color.wordyBlack, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // 다음 버튼 (항상 표시, 답 선택 여부에 따라 enable/disable)
                            Button(action: {
                                if quizViewModel.selectedAnswer != nil {
                                    quizViewModel.nextQuestion()
                                }
                            }) {
                                Text("Next")
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.vertical, 20)
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(quizViewModel.selectedAnswer != nil ? 
                                                Color.wordyBlack : Color.clear)
                                    )
                                    .foregroundColor(quizViewModel.selectedAnswer != nil ? .white : .wordyBlack)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.wordyBlack, lineWidth: 1)
                                    )
                            }
                            .disabled(quizViewModel.selectedAnswer == nil)
                            .opacity(quizViewModel.selectedAnswer == nil ? 0.5 : 1.0)
                            .padding(.horizontal, 20)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 40)
                        
                        Spacer()
                    }
                    .background(
                        quizViewModel.currentQuestionIndex == 0 ? Color.wordyGreen : Color.wordyYellow
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            quizViewModel.generateQuestions(from: words, setting: currentSetting)
        }
        .alert("테스트 종료", isPresented: $showingEndAlert) {
            Button("확인") {
                dismiss()
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("테스트를 종료하고 홈으로 돌아가시겠습니까?")
        }
    }
}

struct QuizResultView: View {
    let score: Int
    let totalQuestions: Int
    let onRestart: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("테스트 완료")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.wordyBlack)
                
                Text("점수: \(score)/\(totalQuestions)")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.wordyBlack)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    onRestart()
                }) {
                    Text("다시 시도")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.wordyBlack)
                        )
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.wordyBlack, lineWidth: 1)
                        )
                }
                
                Button(action: {
                    onClose()
                }) {
                    Text("닫기")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.clear)
                        )
                        .foregroundColor(.wordyBlack)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.wordyBlack, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.wordyYellow.ignoresSafeArea())
    }
}

#Preview {
    TestView()
        .modelContainer(for: [Word.self, Setting.self], inMemory: true)
} 
