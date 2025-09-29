//
//  ProgressView.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var userProgressService: UserProgressService
    @State private var selectedTimeframe: TimeFrame = .week
    @State private var showAchievements = false
    
    enum TimeFrame: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case all = "All Time"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                HeaderView()
                
                // Time frame selector
                TimeFrameSelector()
                
                // Stats overview
                StatsOverview()
                
                // Progress charts
                ProgressCharts()
                
                // Achievements preview
                AchievementsPreview()
                
                // Streak calendar
                StreakCalendar()
                
                Spacer(minLength: 100) // Space for tab bar
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "525152"),
                    Color(hex: "152842")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
                .environmentObject(userProgressService)
        }
    }
    
    @ViewBuilder
    private func HeaderView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Progress")
                    .font(.largeTitle)
                    
                    .foregroundColor(.white)
                
                Text("Track your learning journey")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button("Achievements") {
                showAchievements = true
            }
            .font(.headline)
            .foregroundColor(Color(hex: "F8C029"))
        }
    }
    
    @ViewBuilder
    private func TimeFrameSelector() -> some View {
        HStack(spacing: 0) {
            ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                Button(timeframe.rawValue) {
                    selectedTimeframe = timeframe
                }
                .font(.subheadline)
                .foregroundColor(selectedTimeframe == timeframe ? Color(hex: "152842") : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    selectedTimeframe == timeframe ? Color(hex: "F8C029") : Color.clear
                )
                .animation(.easeInOut(duration: 0.2), value: selectedTimeframe)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private func StatsOverview() -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            StatCard(
                title: "Total XP",
                value: "\(userProgressService.currentUser?.totalXP ?? 0)",
                icon: "star.fill",
                color: Color(hex: "F8C029")
            )
            
            StatCard(
                title: "Current Level",
                value: "\(userProgressService.currentUser?.currentLevel ?? 1)",
                icon: "crown.fill",
                color: Color(hex: "0954A6")
            )
            
            StatCard(
                title: "Lessons Completed",
                value: "\(userProgressService.currentUser?.completedLessons.count ?? 0)",
                icon: "book.fill",
                color: .green
            )
            
            StatCard(
                title: "Current Streak",
                value: "\(userProgressService.currentUser?.currentStreak ?? 0)",
                icon: "flame.fill",
                color: .orange
            )
        }
    }
    
    @ViewBuilder
    private func ProgressCharts() -> some View {
        VStack(spacing: 20) {
            // XP Progress Chart
            XPProgressChart()
            
            // Daily Goal Progress
            DailyGoalProgress()
        }
    }
    
    @ViewBuilder
    private func XPProgressChart() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("XP Progress")
                .font(.title2)
                
                .foregroundColor(.white)
            
            // Simple bar chart representation
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7) { index in
                    VStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "F8C029"))
                            .frame(width: 30, height: CGFloat.random(in: 20...80))
                        
                        Text(dayAbbreviation(for: index))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private func DailyGoalProgress() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Daily Goal")
                    .font(.title2)
                    
                    .foregroundColor(.white)
                
                Spacer()
                
                if let user = userProgressService.currentUser {
                    Text("\(userProgressService.userProgress.dailyXP)/\(user.learningGoal.dailyGoalXP) XP")
                        .font(.headline)
                        .foregroundColor(Color(hex: "F8C029"))
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "F8C029"))
                        .frame(width: geometry.size.width * dailyGoalProgress, height: 12)
                        .animation(.easeInOut(duration: 0.5), value: dailyGoalProgress)
                }
            }
            .frame(height: 12)
            
            Text(dailyGoalText)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private func AchievementsPreview() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recent Achievements")
                    .font(.title2)
                    
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    showAchievements = true
                }
                .font(.subheadline)
                .foregroundColor(Color(hex: "F8C029"))
            }
            
            let recentAchievements = userProgressService.achievements
                .filter { $0.isUnlocked }
                .sorted { ($0.unlockedDate ?? Date.distantPast) > ($1.unlockedDate ?? Date.distantPast) }
                .prefix(3)
            
            if recentAchievements.isEmpty {
                EmptyAchievementsView()
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(recentAchievements), id: \.id) { achievement in
                        AchievementRowView(achievement: achievement)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private func StreakCalendar() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Streak Calendar")
                .font(.title2)
                
                .foregroundColor(.white)
            
            // Simple calendar grid showing last 30 days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<30) { day in
                    Circle()
                        .fill(streakColor(for: day))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text("\(day + 1)")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                }
            }
            
            HStack(spacing: 20) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color(hex: "F8C029"))
                        .frame(width: 12, height: 12)
                    Text("Active")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                HStack(spacing: 5) {
                    Circle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                    Text("Inactive")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    // MARK: - Helper Views and Functions
    
    private var dailyGoalProgress: Double {
        guard let user = userProgressService.currentUser else { return 0.0 }
        let dailyGoal = user.learningGoal.dailyGoalXP
        return dailyGoal > 0 ? Double(userProgressService.userProgress.dailyXP) / Double(dailyGoal) : 0.0
    }
    
    private var dailyGoalText: String {
        if dailyGoalProgress >= 1.0 {
            return "🎉 Daily goal achieved!"
        } else {
            guard let user = userProgressService.currentUser else { return "" }
            let remaining = user.learningGoal.dailyGoalXP - userProgressService.userProgress.dailyXP
            return "\(remaining) XP to reach your daily goal"
        }
    }
    
    private func dayAbbreviation(for index: Int) -> String {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return days[index % 7]
    }
    
    private func streakColor(for day: Int) -> Color {
        // Simple logic - show active for recent days based on current streak
        let currentStreak = userProgressService.currentUser?.currentStreak ?? 0
        return day < currentStreak ? Color(hex: "F8C029") : Color.gray.opacity(0.3)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(value)
                    .font(.title)
                    
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct AchievementRowView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: achievement.category.color).opacity(0.2))
                    .frame(width: 35, height: 35)
                
                Image(systemName: achievement.iconName)
                    .foregroundColor(Color(hex: achievement.category.color))
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text("+\(achievement.xpReward)")
                .font(.caption)
                
                .foregroundColor(Color(hex: "F8C029"))
        }
        .padding(.vertical, 5)
    }
}

struct EmptyAchievementsView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "trophy")
                .font(.system(size: 30))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No achievements yet")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Complete lessons to unlock achievements!")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(20)
    }
}

#Preview {
    ProgressView()
        .environmentObject(UserProgressService())
}

