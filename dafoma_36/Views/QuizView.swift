//
//  QuizView.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct QuizView: View {
    let lesson: Lesson
    @EnvironmentObject var userProgressService: UserProgressService
    @EnvironmentObject var lessonService: LessonService
    @StateObject private var viewModel: QuizViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showExitAlert = false
    
    init(lesson: Lesson) {
        self.lesson = lesson
        self._viewModel = StateObject(wrappedValue: QuizViewModel(
            lessonService: LessonService(),
            userProgressService: UserProgressService()
        ))
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "525152"),
                    Color(hex: "152842")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                QuizHeader()
                
                if viewModel.showResults {
                    // Results View
                    QuizResultsView()
                } else {
                    // Quiz Content
                    QuizContentView()
                }
            }
        }
        .onAppear {
            viewModel.lessonService = lessonService
            viewModel.userProgressService = userProgressService
            lessonService.startLesson(lesson)
        }
        .alert("Exit Quiz?", isPresented: $showExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Your progress will be lost if you exit now.")
        }
    }
    
    @ViewBuilder
    private func QuizHeader() -> some View {
        VStack(spacing: 15) {
            HStack {
                Button("Exit") {
                    showExitAlert = true
                }
                .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                if !viewModel.showResults {
                    Text("\(viewModel.currentQuestionIndex + 1) of \(viewModel.totalQuestions)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if !viewModel.showResults && viewModel.timeRemaining > 0 {
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .foregroundColor(viewModel.timeRemaining <= 5 ? .red : Color(hex: "F8C029"))
                        
                        Text("\(viewModel.timeRemaining)")
                            .font(.headline)
                            .foregroundColor(viewModel.timeRemaining <= 5 ? .red : Color(hex: "F8C029"))
                    }
                }
            }
            
            // Progress bar
            if !viewModel.showResults {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "F8C029"))
                            .frame(width: geometry.size.width * viewModel.progressPercentage, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.progressPercentage)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    @ViewBuilder
    private func QuizContentView() -> some View {
        ScrollView {
            VStack(spacing: 30) {
                if let question = viewModel.currentQuestion {
                    // Question
                    QuestionView(question: question)
                    
                    // Answer options or input
                    AnswerSection(question: question)
                    
                    // Explanation (if shown)
                    if viewModel.showExplanation, let explanation = question.explanation {
                        ExplanationView(explanation: explanation, isCorrect: viewModel.isCorrect)
                    }
                    
                    // Action buttons
                    ActionButtons()
                }
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    @ViewBuilder
    private func QuizResultsView() -> some View {
        ScrollView {
            VStack(spacing: 30) {
                // Results header
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "F8C029").opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: viewModel.finalScore >= 70 ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "F8C029"))
                    }
                    
                    Text("Quiz Complete!")
                        .font(.title)
                        
                        .foregroundColor(.white)
                    
                    Text("You scored \(Int(viewModel.finalScore))%")
                        .font(.title2)
                        .foregroundColor(Color(hex: "F8C029"))
                }
                
                // Stats
                VStack(spacing: 15) {
                    StatRow(title: "Correct Answers", value: "\(viewModel.correctAnswers)/\(viewModel.totalQuestions)")
                    StatRow(title: "Accuracy", value: "\(Int(viewModel.finalScore))%")
                    StatRow(title: "XP Earned", value: "\(calculateXPEarned()) XP")
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )
                
                // Action buttons
                VStack(spacing: 15) {
                    Button("Continue Learning") {
                        dismiss()
                    }
                    .font(.headline)
                    
                    .foregroundColor(Color(hex: "152842"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "F8C029"))
                    .cornerRadius(12)
                    
                    Button("Retry Quiz") {
                        viewModel.resetQuiz()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    @ViewBuilder
    private func QuestionView(question: Question) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Question")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            Text(question.prompt)
                .font(.title2)
                
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private func AnswerSection(question: Question) -> some View {
        VStack(spacing: 15) {
            switch question.type {
            case .multipleChoice:
                MultipleChoiceAnswers(question: question)
            case .fillInTheBlank, .translation:
                TextInputAnswer(question: question)
            default:
                MultipleChoiceAnswers(question: question)
            }
        }
    }
    
    @ViewBuilder
    private func MultipleChoiceAnswers(question: Question) -> some View {
        VStack(spacing: 12) {
            ForEach(question.options ?? [], id: \.self) { option in
                AnswerOptionButton(
                    text: option,
                    isSelected: viewModel.selectedAnswer == option,
                    isCorrect: viewModel.isAnswerSubmitted ? option == question.correctAnswer : nil,
                    isSubmitted: viewModel.isAnswerSubmitted
                ) {
                    viewModel.selectAnswer(option)
                }
            }
        }
    }
    
    @ViewBuilder
    private func TextInputAnswer(question: Question) -> some View {
        VStack(spacing: 15) {
            TextField("Type your answer...", text: $viewModel.selectedAnswer)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    viewModel.isAnswerSubmitted ?
                                    (viewModel.isCorrect ? Color.green : Color.red) :
                                    Color.white.opacity(0.3),
                                    lineWidth: 2
                                )
                        )
                )
                .disabled(viewModel.isAnswerSubmitted)
        }
    }
    
    @ViewBuilder
    private func AnswerOptionButton(text: String, isSelected: Bool, isCorrect: Bool?, isSubmitted: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.headline)
                    .foregroundColor(getTextColor(isSubmitted: isSubmitted, isCorrect: isCorrect, isSelected: isSelected))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSubmitted && isCorrect == true {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if isSubmitted && isCorrect == false {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(getBackgroundColor(isSubmitted: isSubmitted, isCorrect: isCorrect, isSelected: isSelected))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(getBorderColor(isSubmitted: isSubmitted, isCorrect: isCorrect, isSelected: isSelected), lineWidth: 2)
                    )
            )
        }
        .disabled(isSubmitted)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isSubmitted)
    }
    
    @ViewBuilder
    private func ExplanationView(explanation: String, isCorrect: Bool) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "info.circle.fill")
                .foregroundColor(isCorrect ? .green : Color(hex: "F8C029"))
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(isCorrect ? "Correct!" : "Learn More")
                    .font(.headline)
                    .foregroundColor(isCorrect ? .green : Color(hex: "F8C029"))
                
                Text(explanation)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isCorrect ? Color.green.opacity(0.3) : Color(hex: "F8C029").opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func ActionButtons() -> some View {
        HStack(spacing: 15) {
            if !viewModel.isAnswerSubmitted {
                Button("Skip") {
                    viewModel.skipQuestion()
                }
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                
                Button("Submit") {
                    viewModel.submitAnswer()
                }
                .font(.headline)
                
                .foregroundColor(Color(hex: "152842"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    viewModel.selectedAnswer.isEmpty ? Color.gray.opacity(0.5) : Color(hex: "F8C029")
                )
                .cornerRadius(12)
                .disabled(viewModel.selectedAnswer.isEmpty)
            } else {
                Button("Next") {
                    viewModel.nextQuestion()
                }
                .font(.headline)
                
                .foregroundColor(Color(hex: "152842"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "F8C029"))
                .cornerRadius(12)
            }
        }
    }
    
    @ViewBuilder
    private func StatRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.headline)
                
                .foregroundColor(Color(hex: "F8C029"))
        }
    }
    
    private func calculateXPEarned() -> Int {
        let baseXP = lesson.xpReward
        let accuracyMultiplier = viewModel.finalScore / 100.0
        return Int(Double(baseXP) * accuracyMultiplier)
    }
    
    private func getTextColor(isSubmitted: Bool, isCorrect: Bool?, isSelected: Bool) -> Color {
        if isSubmitted {
            return .white
        } else {
            return isSelected ? Color(hex: "152842") : .white
        }
    }
    
    private func getBackgroundColor(isSubmitted: Bool, isCorrect: Bool?, isSelected: Bool) -> Color {
        if isSubmitted {
            if isCorrect == true {
                return Color.green.opacity(0.3)
            } else if isCorrect == false {
                return Color.red.opacity(0.3)
            } else {
                return Color.white.opacity(0.1)
            }
        } else {
            return isSelected ? Color(hex: "F8C029") : Color.white.opacity(0.1)
        }
    }
    
    private func getBorderColor(isSubmitted: Bool, isCorrect: Bool?, isSelected: Bool) -> Color {
        if isSubmitted {
            if isCorrect == true {
                return Color.green
            } else if isCorrect == false {
                return Color.red
            } else {
                return Color.white.opacity(0.3)
            }
        } else {
            return isSelected ? Color(hex: "F8C029") : Color.white.opacity(0.3)
        }
    }
}

#Preview {
    let sampleLesson = Lesson(
        id: "sample",
        title: "Basic Greetings",
        description: "Learn essential greetings",
        language: "Spanish",
        difficulty: .beginner,
        estimatedDuration: 10,
        xpReward: 25,
        moduleId: "spanish_basics",
        order: 1,
        questions: [
            Question(id: "q1", type: .multipleChoice, prompt: "How do you say 'Hello' in Spanish?", 
                    correctAnswer: "Hola", options: ["Hola", "Adios", "Gracias", "Por favor"])
        ]
    )
    
    QuizView(lesson: sampleLesson)
        .environmentObject(UserProgressService())
        .environmentObject(LessonService())
}
