//
//  QuizViewModel.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation
import Combine

class QuizViewModel: ObservableObject {
    @Published var currentQuestion: Question?
    @Published var currentQuestionIndex: Int = 0
    @Published var totalQuestions: Int = 0
    @Published var selectedAnswer: String = ""
    @Published var isAnswerSubmitted: Bool = false
    @Published var isCorrect: Bool = false
    @Published var showExplanation: Bool = false
    @Published var correctAnswers: Int = 0
    @Published var lessonCompleted: Bool = false
    @Published var finalScore: Double = 0.0
    @Published var timeRemaining: Int = 0
    @Published var showResults: Bool = false
    
    var lessonService: LessonService
    var userProgressService: UserProgressService
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private let questionTimeLimit: Int = 30 // seconds
    
    init(lessonService: LessonService, userProgressService: UserProgressService) {
        self.lessonService = lessonService
        self.userProgressService = userProgressService
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Update current question when lesson progress changes
        lessonService.$lessonProgress
            .compactMap { $0 }
            .sink { [weak self] progress in
                self?.currentQuestionIndex = progress.currentQuestionIndex
                self?.correctAnswers = progress.correctAnswers
                self?.lessonCompleted = progress.isCompleted
                self?.finalScore = progress.score
                
                if progress.isCompleted {
                    self?.showResults = true
                    self?.completeLesson()
                } else {
                    self?.loadCurrentQuestion()
                }
            }
            .store(in: &cancellables)
        
        lessonService.$currentLesson
            .compactMap { $0 }
            .sink { [weak self] lesson in
                self?.totalQuestions = lesson.questions.count
                self?.loadCurrentQuestion()
            }
            .store(in: &cancellables)
    }
    
    private func loadCurrentQuestion() {
        currentQuestion = lessonService.getCurrentQuestion()
        selectedAnswer = ""
        isAnswerSubmitted = false
        isCorrect = false
        showExplanation = false
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timeRemaining = questionTimeLimit
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timeUp()
            }
        }
    }
    
    private func timeUp() {
        timer?.invalidate()
        if !isAnswerSubmitted {
            submitAnswer()
        }
    }
    
    func selectAnswer(_ answer: String) {
        guard !isAnswerSubmitted else { return }
        selectedAnswer = answer
    }
    
    func submitAnswer() {
        guard !isAnswerSubmitted else { return }
        guard !selectedAnswer.isEmpty else { return }
        
        timer?.invalidate()
        isAnswerSubmitted = true
        
        let correct = lessonService.submitAnswer(for: currentQuestion?.id ?? "", answer: selectedAnswer)
        isCorrect = correct
        
        if let explanation = currentQuestion?.explanation, !explanation.isEmpty {
            showExplanation = true
        }
        
        // Auto-advance after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.nextQuestion()
        }
    }
    
    func nextQuestion() {
        if lessonCompleted {
            showResults = true
        } else {
            loadCurrentQuestion()
        }
    }
    
    private func completeLesson() {
        guard let lesson = lessonService.currentLesson else { return }
        
        let xpEarned = calculateXPEarned()
        userProgressService.completeLesson(lesson.id, xpEarned: xpEarned)
    }
    
    private func calculateXPEarned() -> Int {
        guard let lesson = lessonService.currentLesson else { return 0 }
        
        let baseXP = lesson.xpReward
        let accuracyMultiplier = finalScore / 100.0
        
        return Int(Double(baseXP) * accuracyMultiplier)
    }
    
    func resetQuiz() {
        lessonService.resetLesson()
        selectedAnswer = ""
        isAnswerSubmitted = false
        isCorrect = false
        showExplanation = false
        correctAnswers = 0
        lessonCompleted = false
        finalScore = 0.0
        showResults = false
        timer?.invalidate()
    }
    
    func skipQuestion() {
        guard !isAnswerSubmitted else { return }
        
        // Submit empty answer (counts as incorrect)
        selectedAnswer = currentQuestion?.correctAnswer ?? ""
        submitAnswer()
    }
    
    deinit {
        timer?.invalidate()
    }
}

// MARK: - Computed Properties
extension QuizViewModel {
    var progressPercentage: Double {
        guard totalQuestions > 0 else { return 0.0 }
        return Double(currentQuestionIndex) / Double(totalQuestions)
    }
    
    var questionsRemaining: Int {
        return totalQuestions - currentQuestionIndex
    }
    
    var accuracyPercentage: Double {
        guard currentQuestionIndex > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(currentQuestionIndex) * 100.0
    }
}
