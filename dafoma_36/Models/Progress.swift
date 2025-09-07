//
//  Progress.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation

struct UserProgress: Codable {
    var dailyXP: Int
    var weeklyXP: Int
    var monthlyXP: Int
    var lastUpdated: Date
    var dailyGoalMet: Bool
    var weeklyGoalMet: Bool
    var monthlyGoalMet: Bool
    
    init() {
        self.dailyXP = 0
        self.weeklyXP = 0
        self.monthlyXP = 0
        self.lastUpdated = Date()
        self.dailyGoalMet = false
        self.weeklyGoalMet = false
        self.monthlyGoalMet = false
    }
    
    mutating func addXP(_ xp: Int) {
        let calendar = Calendar.current
        let now = Date()
        
        // Reset daily XP if it's a new day
        if !calendar.isDate(lastUpdated, inSameDayAs: now) {
            dailyXP = 0
            dailyGoalMet = false
        }
        
        // Reset weekly XP if it's a new week
        if !calendar.isDate(lastUpdated, equalTo: now, toGranularity: .weekOfYear) {
            weeklyXP = 0
            weeklyGoalMet = false
        }
        
        // Reset monthly XP if it's a new month
        if !calendar.isDate(lastUpdated, equalTo: now, toGranularity: .month) {
            monthlyXP = 0
            monthlyGoalMet = false
        }
        
        dailyXP += xp
        weeklyXP += xp
        monthlyXP += xp
        lastUpdated = now
    }
}

struct LessonProgress: Codable, Identifiable {
    let id: String
    let lessonId: String
    var isCompleted: Bool
    var currentQuestionIndex: Int
    var correctAnswers: Int
    var totalQuestions: Int
    var timeSpent: TimeInterval
    var attempts: Int
    var lastAttemptDate: Date?
    var score: Double
    
    init(lessonId: String, totalQuestions: Int) {
        self.id = UUID().uuidString
        self.lessonId = lessonId
        self.isCompleted = false
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.totalQuestions = totalQuestions
        self.timeSpent = 0
        self.attempts = 0
        self.lastAttemptDate = nil
        self.score = 0.0
    }
    
    var completionPercentage: Double {
        guard totalQuestions > 0 else { return 0.0 }
        return Double(currentQuestionIndex) / Double(totalQuestions) * 100.0
    }
    
    var accuracy: Double {
        guard currentQuestionIndex > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(currentQuestionIndex) * 100.0
    }
}

struct StreakData: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDate: Date
    var streakStartDate: Date?
    
    init() {
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastActiveDate = Date()
        self.streakStartDate = nil
    }
    
    mutating func updateStreak() {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(lastActiveDate, inSameDayAs: now) {
            // Same day, no change needed
            return
        }
        
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(lastActiveDate, inSameDayAs: yesterday) {
            // Consecutive day
            currentStreak += 1
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
        } else {
            // Streak broken
            currentStreak = 1
            streakStartDate = now
        }
        
        lastActiveDate = now
    }
}
