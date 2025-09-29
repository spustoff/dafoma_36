//
//  User.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id = UUID()
    var name: String
    var email: String
    var currentStreak: Int
    var longestStreak: Int
    var totalXP: Int
    var currentLevel: Int
    var profileImageName: String?
    var joinDate: Date
    var lastActiveDate: Date
    var preferredLanguages: [String]
    var learningGoal: LearningGoal
    var achievements: [Achievement]
    var completedLessons: [String] // Lesson IDs
    
    init(name: String, email: String, preferredLanguages: [String] = [], learningGoal: LearningGoal = .casual) {
        self.name = name
        self.email = email
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalXP = 0
        self.currentLevel = 1
        self.profileImageName = nil
        self.joinDate = Date()
        self.lastActiveDate = Date()
        self.preferredLanguages = preferredLanguages
        self.learningGoal = learningGoal
        self.achievements = []
        self.completedLessons = []
    }
}

enum LearningGoal: String, CaseIterable, Codable {
    case casual = "Casual Learning"
    case regular = "Regular Practice"
    case intensive = "Intensive Study"
    case fluent = "Fluency Goal"
    
    var dailyGoalMinutes: Int {
        switch self {
        case .casual: return 5
        case .regular: return 15
        case .intensive: return 30
        case .fluent: return 60
        }
    }
    
    var dailyGoalXP: Int {
        switch self {
        case .casual: return 20
        case .regular: return 50
        case .intensive: return 100
        case .fluent: return 200
        }
    }
}

