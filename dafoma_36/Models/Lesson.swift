//
//  Lesson.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation

struct Lesson: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let language: String
    let difficulty: Difficulty
    let estimatedDuration: Int // minutes
    let xpReward: Int
    let moduleId: String
    let order: Int
    let isLocked: Bool
    let questions: [Question]
    let imageUrl: String?
    
    init(id: String, title: String, description: String, language: String, 
         difficulty: Difficulty, estimatedDuration: Int, xpReward: Int, 
         moduleId: String, order: Int, isLocked: Bool = false, questions: [Question] = [], imageUrl: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.language = language
        self.difficulty = difficulty
        self.estimatedDuration = estimatedDuration
        self.xpReward = xpReward
        self.moduleId = moduleId
        self.order = order
        self.isLocked = isLocked
        self.questions = questions
        self.imageUrl = imageUrl
    }
}

enum Difficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var color: String {
        switch self {
        case .beginner: return "#4CAF50"
        case .intermediate: return "#FF9800"
        case .advanced: return "#F44336"
        case .expert: return "#9C27B0"
        }
    }
}

struct Question: Codable, Identifiable {
    let id: String
    let type: QuestionType
    let prompt: String
    let options: [String]?
    let correctAnswer: String
    let explanation: String?
    let audioUrl: String?
    let imageUrl: String?
    
    init(id: String, type: QuestionType, prompt: String, correctAnswer: String, 
         options: [String]? = nil, explanation: String? = nil, audioUrl: String? = nil, imageUrl: String? = nil) {
        self.id = id
        self.type = type
        self.prompt = prompt
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.audioUrl = audioUrl
        self.imageUrl = imageUrl
    }
}

enum QuestionType: String, CaseIterable, Codable {
    case multipleChoice = "Multiple Choice"
    case fillInTheBlank = "Fill in the Blank"
    case translation = "Translation"
    case listening = "Listening"
    case speaking = "Speaking"
    case matching = "Matching"
}

struct LearningModule: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let language: String
    let iconName: String
    let color: String
    let lessons: [Lesson]
    let isUnlocked: Bool
    let completionPercentage: Double
    
    init(id: String, title: String, description: String, language: String, 
         iconName: String, color: String, lessons: [Lesson] = [], 
         isUnlocked: Bool = true, completionPercentage: Double = 0.0) {
        self.id = id
        self.title = title
        self.description = description
        self.language = language
        self.iconName = iconName
        self.color = color
        self.lessons = lessons
        self.isUnlocked = isUnlocked
        self.completionPercentage = completionPercentage
    }
}
