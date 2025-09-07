//
//  HomeViewModel.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var greeting: String = ""
    @Published var dailyGoalProgress: Double = 0.0
    @Published var streakCount: Int = 0
    @Published var todayXP: Int = 0
    @Published var recommendedLessons: [Lesson] = []
    @Published var recentAchievements: [Achievement] = []
    @Published var isLoading: Bool = false
    
    var userProgressService: UserProgressService
    var lessonService: LessonService
    private var cancellables = Set<AnyCancellable>()
    
    init(userProgressService: UserProgressService, lessonService: LessonService) {
        self.userProgressService = userProgressService
        self.lessonService = lessonService
        
        setupBindings()
        updateGreeting()
        loadRecommendedLessons()
    }
    
    private func setupBindings() {
        // Update streak count when user changes
        userProgressService.$currentUser
            .compactMap { $0 }
            .map { $0.currentStreak }
            .assign(to: &$streakCount)
        
        // Update today's XP
        userProgressService.$userProgress
            .map { $0.dailyXP }
            .assign(to: &$todayXP)
        
        // Update daily goal progress
        Publishers.CombineLatest(
            userProgressService.$currentUser.compactMap { $0 },
            userProgressService.$userProgress
        )
        .map { user, progress in
            let dailyGoal = user.learningGoal.dailyGoalXP
            return dailyGoal > 0 ? Double(progress.dailyXP) / Double(dailyGoal) : 0.0
        }
        .assign(to: &$dailyGoalProgress)
        
        // Update recent achievements
        userProgressService.$achievements
            .map { achievements in
                achievements
                    .filter { $0.isUnlocked }
                    .sorted { ($0.unlockedDate ?? Date.distantPast) > ($1.unlockedDate ?? Date.distantPast) }
                    .prefix(3)
                    .map { $0 }
            }
            .assign(to: &$recentAchievements)
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<12:
            greeting = "Good morning! 🌅"
        case 12..<17:
            greeting = "Good afternoon! ☀️"
        case 17..<21:
            greeting = "Good evening! 🌆"
        default:
            greeting = "Good night! 🌙"
        }
    }
    
    private func loadRecommendedLessons() {
        isLoading = true
        
        // Simulate async loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Get lessons based on user's preferred languages
            let allLessons = self.lessonService.availableModules.flatMap { $0.lessons }
            let completedLessonIds = self.userProgressService.currentUser?.completedLessons ?? []
            
            // Filter out completed lessons and get next recommended ones
            let availableLessons = allLessons.filter { !completedLessonIds.contains($0.id) && !$0.isLocked }
            
            self.recommendedLessons = Array(availableLessons.prefix(3))
            self.isLoading = false
        }
    }
    
    func refreshData() {
        updateGreeting()
        loadRecommendedLessons()
    }
    
    func startLesson(_ lesson: Lesson) {
        lessonService.startLesson(lesson)
    }
}
