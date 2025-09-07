//
//  LessonService.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation
import Combine

class LessonService: ObservableObject {
    @Published var availableModules: [LearningModule] = []
    @Published var currentLesson: Lesson?
    @Published var lessonProgress: LessonProgress?
    
    init() {
        loadSampleData()
    }
    
    // MARK: - Module Management
    
    func getModule(by id: String) -> LearningModule? {
        return availableModules.first { $0.id == id }
    }
    
    func getLesson(by id: String) -> Lesson? {
        for module in availableModules {
            if let lesson = module.lessons.first(where: { $0.id == id }) {
                return lesson
            }
        }
        return nil
    }
    
    // MARK: - Lesson Progress
    
    func startLesson(_ lesson: Lesson) {
        currentLesson = lesson
        lessonProgress = LessonProgress(lessonId: lesson.id, totalQuestions: lesson.questions.count)
    }
    
    func submitAnswer(for questionId: String, answer: String) -> Bool {
        guard let lesson = currentLesson,
              let progress = lessonProgress else { return false }
        
        let currentQuestionIndex = progress.currentQuestionIndex
        guard currentQuestionIndex < lesson.questions.count else { return false }
        
        let question = lesson.questions[currentQuestionIndex]
        let isCorrect = question.correctAnswer.lowercased() == answer.lowercased()
        
        var updatedProgress = progress
        if isCorrect {
            updatedProgress.correctAnswers += 1
        }
        updatedProgress.currentQuestionIndex += 1
        
        // Check if lesson is completed
        if updatedProgress.currentQuestionIndex >= lesson.questions.count {
            updatedProgress.isCompleted = true
            updatedProgress.score = Double(updatedProgress.correctAnswers) / Double(lesson.questions.count) * 100.0
            updatedProgress.lastAttemptDate = Date()
            updatedProgress.attempts += 1
        }
        
        lessonProgress = updatedProgress
        return isCorrect
    }
    
    func getCurrentQuestion() -> Question? {
        guard let lesson = currentLesson,
              let progress = lessonProgress,
              progress.currentQuestionIndex < lesson.questions.count else { return nil }
        
        return lesson.questions[progress.currentQuestionIndex]
    }
    
    func resetLesson() {
        guard let lesson = currentLesson else { return }
        lessonProgress = LessonProgress(lessonId: lesson.id, totalQuestions: lesson.questions.count)
    }
    
    // MARK: - Sample Data
    
    private func loadSampleData() {
        availableModules = [
            createSpanishBasicsModule(),
            createEnglishConversationModule(),
            createFrenchPronunciationModule()
        ]
    }
    
    private func createSpanishBasicsModule() -> LearningModule {
        let questions1 = [
            Question(id: "q1", type: .multipleChoice, prompt: "How do you say 'Hello' in Spanish?", 
                    correctAnswer: "Hola", options: ["Hola", "Adios", "Gracias", "Por favor"]),
            Question(id: "q2", type: .multipleChoice, prompt: "What does 'Gracias' mean?", 
                    correctAnswer: "Thank you", options: ["Hello", "Thank you", "Goodbye", "Please"]),
            Question(id: "q3", type: .fillInTheBlank, prompt: "Complete: 'Me llamo ___' (My name is)", 
                    correctAnswer: "Maria", explanation: "This is how you introduce yourself in Spanish.")
        ]
        
        let questions2 = [
            Question(id: "q4", type: .multipleChoice, prompt: "How do you say 'Good morning' in Spanish?", 
                    correctAnswer: "Buenos días", options: ["Buenas noches", "Buenos días", "Buenas tardes", "Hola"]),
            Question(id: "q5", type: .translation, prompt: "Translate: 'I am fine'", 
                    correctAnswer: "Estoy bien"),
            Question(id: "q6", type: .multipleChoice, prompt: "What is 'water' in Spanish?", 
                    correctAnswer: "Agua", options: ["Leche", "Agua", "Café", "Té"])
        ]
        
        let lessons = [
            Lesson(id: "spanish_greetings", title: "Basic Greetings", description: "Learn essential Spanish greetings", 
                  language: "Spanish", difficulty: .beginner, estimatedDuration: 10, xpReward: 25, 
                  moduleId: "spanish_basics", order: 1, questions: questions1),
            Lesson(id: "spanish_introductions", title: "Introductions", description: "How to introduce yourself in Spanish", 
                  language: "Spanish", difficulty: .beginner, estimatedDuration: 15, xpReward: 30, 
                  moduleId: "spanish_basics", order: 2, questions: questions2)
        ]
        
        return LearningModule(id: "spanish_basics", title: "Spanish Basics", 
                            description: "Start your Spanish journey with essential phrases", 
                            language: "Spanish", iconName: "flag.fill", color: "#FF6B35", lessons: lessons)
    }
    
    private func createEnglishConversationModule() -> LearningModule {
        let questions1 = [
            Question(id: "e1", type: .multipleChoice, prompt: "Which is the correct response to 'How are you?'", 
                    correctAnswer: "I'm fine, thank you", options: ["I'm fine, thank you", "Yes, please", "Goodbye", "Hello"]),
            Question(id: "e2", type: .fillInTheBlank, prompt: "Complete: 'Nice to ___ you'", 
                    correctAnswer: "meet"),
            Question(id: "e3", type: .multipleChoice, prompt: "How do you ask for someone's name politely?", 
                    correctAnswer: "What's your name?", options: ["What's your name?", "Who you?", "Name?", "Tell name"])
        ]
        
        let lessons = [
            Lesson(id: "english_small_talk", title: "Small Talk", description: "Master casual English conversations", 
                  language: "English", difficulty: .intermediate, estimatedDuration: 20, xpReward: 40, 
                  moduleId: "english_conversation", order: 1, questions: questions1)
        ]
        
        return LearningModule(id: "english_conversation", title: "English Conversation", 
                            description: "Improve your English speaking skills", 
                            language: "English", iconName: "bubble.left.and.bubble.right.fill", 
                            color: "#0954A6", lessons: lessons)
    }
    
    private func createFrenchPronunciationModule() -> LearningModule {
        let questions1 = [
            Question(id: "f1", type: .multipleChoice, prompt: "How do you pronounce 'Bonjour'?", 
                    correctAnswer: "bon-ZHOOR", options: ["BON-jour", "bon-ZHOOR", "bon-JOOR", "BON-zhoor"]),
            Question(id: "f2", type: .listening, prompt: "Listen and repeat: 'Comment allez-vous?'", 
                    correctAnswer: "Comment allez-vous?", audioUrl: "french_greeting.mp3")
        ]
        
        let lessons = [
            Lesson(id: "french_pronunciation", title: "French Sounds", description: "Master French pronunciation", 
                  language: "French", difficulty: .intermediate, estimatedDuration: 25, xpReward: 50, 
                  moduleId: "french_pronunciation", order: 1, questions: questions1)
        ]
        
        return LearningModule(id: "french_pronunciation", title: "French Pronunciation", 
                            description: "Perfect your French accent", 
                            language: "French", iconName: "waveform", color: "#F8C029", lessons: lessons)
    }
}
