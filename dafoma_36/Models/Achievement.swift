//
//  Achievement.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation

struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let category: AchievementCategory
    let requirement: AchievementRequirement
    let xpReward: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    var progress: Double // 0.0 to 1.0
    
    init(id: String, title: String, description: String, iconName: String, 
         category: AchievementCategory, requirement: AchievementRequirement, 
         xpReward: Int, isUnlocked: Bool = false, progress: Double = 0.0) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.category = category
        self.requirement = requirement
        self.xpReward = xpReward
        self.isUnlocked = isUnlocked
        self.unlockedDate = nil
        self.progress = progress
    }
}

enum AchievementCategory: String, CaseIterable, Codable {
    case streak = "Streak"
    case learning = "Learning"
    case mastery = "Mastery"
    case social = "Social"
    case milestone = "Milestone"
    
    var color: String {
        switch self {
        case .streak: return "#FF6B35"
        case .learning: return "#0954A6"
        case .mastery: return "#F8C029"
        case .social: return "#4ECDC4"
        case .milestone: return "#45B7D1"
        }
    }
}

enum AchievementRequirement: Codable {
    case streakDays(Int)
    case lessonsCompleted(Int)
    case xpEarned(Int)
    case perfectScores(Int)
    case languagesStarted(Int)
    case daysActive(Int)
    case questionsAnswered(Int)
    
    var description: String {
        switch self {
        case .streakDays(let days):
            return "Maintain a \(days)-day streak"
        case .lessonsCompleted(let count):
            return "Complete \(count) lessons"
        case .xpEarned(let xp):
            return "Earn \(xp) XP"
        case .perfectScores(let count):
            return "Get \(count) perfect scores"
        case .languagesStarted(let count):
            return "Start learning \(count) languages"
        case .daysActive(let days):
            return "Be active for \(days) days"
        case .questionsAnswered(let count):
            return "Answer \(count) questions correctly"
        }
    }
    
    func checkProgress(user: User, progress: UserProgress) -> Double {
        switch self {
        case .streakDays(let required):
            return min(Double(user.currentStreak) / Double(required), 1.0)
        case .lessonsCompleted(let required):
            return min(Double(user.completedLessons.count) / Double(required), 1.0)
        case .xpEarned(let required):
            return min(Double(user.totalXP) / Double(required), 1.0)
        case .perfectScores(let required):
            // This would need to be tracked separately
            return 0.0
        case .languagesStarted(let required):
            return min(Double(user.preferredLanguages.count) / Double(required), 1.0)
        case .daysActive(let required):
            let daysSinceJoin = Calendar.current.dateComponents([.day], from: user.joinDate, to: Date()).day ?? 0
            return min(Double(daysSinceJoin) / Double(required), 1.0)
        case .questionsAnswered(let required):
            // This would need to be tracked separately
            return 0.0
        }
    }
}

extension Achievement {
    static let defaultAchievements: [Achievement] = [
        Achievement(
            id: "first_lesson",
            title: "First Steps",
            description: "Complete your first lesson",
            iconName: "star.fill",
            category: .milestone,
            requirement: .lessonsCompleted(1),
            xpReward: 50
        ),
        Achievement(
            id: "week_streak",
            title: "Week Warrior",
            description: "Maintain a 7-day learning streak",
            iconName: "flame.fill",
            category: .streak,
            requirement: .streakDays(7),
            xpReward: 100
        ),
        Achievement(
            id: "hundred_xp",
            title: "Century Club",
            description: "Earn your first 100 XP",
            iconName: "100.square.fill",
            category: .learning,
            requirement: .xpEarned(100),
            xpReward: 25
        ),
        Achievement(
            id: "ten_lessons",
            title: "Dedicated Learner",
            description: "Complete 10 lessons",
            iconName: "book.fill",
            category: .learning,
            requirement: .lessonsCompleted(10),
            xpReward: 150
        ),
        Achievement(
            id: "month_streak",
            title: "Monthly Master",
            description: "Maintain a 30-day learning streak",
            iconName: "calendar.badge.plus",
            category: .streak,
            requirement: .streakDays(30),
            xpReward: 500
        ),
        Achievement(
            id: "thousand_xp",
            title: "XP Collector",
            description: "Earn 1000 XP",
            iconName: "star.circle.fill",
            category: .milestone,
            requirement: .xpEarned(1000),
            xpReward: 200
        )
    ]
}

