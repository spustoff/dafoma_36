//
//  UserProgressService.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation
import Combine

class UserProgressService: ObservableObject {
    @Published var currentUser: User?
    @Published var userProgress: UserProgress = UserProgress()
    @Published var achievements: [Achievement] = Achievement.defaultAchievements
    @Published var hasCompletedOnboarding: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "current_user"
    private let progressKey = "user_progress"
    private let achievementsKey = "user_achievements"
    private let onboardingKey = "has_completed_onboarding"
    
    init() {
        loadUserData()
        loadProgress()
        loadAchievements()
        loadOnboardingStatus()
    }
    
    // MARK: - User Management
    
    func createUser(name: String, email: String, preferredLanguages: [String], learningGoal: LearningGoal) {
        let user = User(name: name, email: email, preferredLanguages: preferredLanguages, learningGoal: learningGoal)
        currentUser = user
        saveUserData()
    }
    
    func updateUser(_ user: User) {
        currentUser = user
        saveUserData()
    }
    
    func deleteAccount() {
        currentUser = nil
        userProgress = UserProgress()
        achievements = Achievement.defaultAchievements
        hasCompletedOnboarding = false
        
        // Clear all stored data
        userDefaults.removeObject(forKey: userKey)
        userDefaults.removeObject(forKey: progressKey)
        userDefaults.removeObject(forKey: achievementsKey)
        userDefaults.removeObject(forKey: onboardingKey)
    }
    
    // MARK: - Progress Management
    
    func addXP(_ xp: Int) {
        guard var user = currentUser else { return }
        
        userProgress.addXP(xp)
        user.totalXP += xp
        
        // Level up logic
        let newLevel = calculateLevel(from: user.totalXP)
        if newLevel > user.currentLevel {
            user.currentLevel = newLevel
            // Could trigger level up celebration here
        }
        
        currentUser = user
        saveUserData()
        saveProgress()
        checkAchievements()
    }
    
    func updateStreak() {
        guard var user = currentUser else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(user.lastActiveDate, inSameDayAs: now) {
            // Same day, no change needed
            return
        }
        
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(user.lastActiveDate, inSameDayAs: yesterday) {
            // Consecutive day
            user.currentStreak += 1
            if user.currentStreak > user.longestStreak {
                user.longestStreak = user.currentStreak
            }
        } else {
            // Streak broken
            user.currentStreak = 1
        }
        
        user.lastActiveDate = now
        currentUser = user
        saveUserData()
        checkAchievements()
    }
    
    func completeLesson(_ lessonId: String, xpEarned: Int) {
        guard var user = currentUser else { return }
        
        if !user.completedLessons.contains(lessonId) {
            user.completedLessons.append(lessonId)
            addXP(xpEarned)
            updateStreak()
        }
        
        currentUser = user
        saveUserData()
    }
    
    // MARK: - Achievements
    
    private func checkAchievements() {
        guard let user = currentUser else { return }
        
        var updatedAchievements = achievements
        var hasNewAchievement = false
        
        for i in 0..<updatedAchievements.count {
            if !updatedAchievements[i].isUnlocked {
                let progress = updatedAchievements[i].requirement.checkProgress(user: user, progress: userProgress)
                updatedAchievements[i].progress = progress
                
                if progress >= 1.0 {
                    updatedAchievements[i].isUnlocked = true
                    updatedAchievements[i].unlockedDate = Date()
                    hasNewAchievement = true
                    
                    // Award XP for achievement
                    addXP(updatedAchievements[i].xpReward)
                }
            }
        }
        
        achievements = updatedAchievements
        saveAchievements()
        
        if hasNewAchievement {
            // Could trigger achievement notification here
        }
    }
    
    // MARK: - Onboarding
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: onboardingKey)
    }
    
    // MARK: - Data Persistence
    
    private func saveUserData() {
        guard let user = currentUser else { return }
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userKey)
        }
    }
    
    private func loadUserData() {
        guard let data = userDefaults.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else { return }
        currentUser = user
    }
    
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            userDefaults.set(encoded, forKey: progressKey)
        }
    }
    
    private func loadProgress() {
        guard let data = userDefaults.data(forKey: progressKey),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else { return }
        userProgress = progress
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            userDefaults.set(encoded, forKey: achievementsKey)
        }
    }
    
    private func loadAchievements() {
        guard let data = userDefaults.data(forKey: achievementsKey),
              let savedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) else { return }
        achievements = savedAchievements
    }
    
    private func loadOnboardingStatus() {
        hasCompletedOnboarding = userDefaults.bool(forKey: onboardingKey)
    }
    
    // MARK: - Helper Methods
    
    private func calculateLevel(from xp: Int) -> Int {
        // Simple level calculation: every 100 XP = 1 level
        return max(1, xp / 100 + 1)
    }
}
