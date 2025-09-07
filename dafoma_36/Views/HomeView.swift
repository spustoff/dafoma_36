//
//  HomeView.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userProgressService: UserProgressService
    @EnvironmentObject var lessonService: LessonService
    @StateObject private var viewModel: HomeViewModel
    @State private var showQuizView = false
    @State private var selectedLesson: Lesson?
    
    init() {
        self._viewModel = StateObject(wrappedValue: HomeViewModel(
            userProgressService: UserProgressService(),
            lessonService: LessonService()
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                HeaderView()
                
                // Daily Progress Card
                DailyProgressCard()
                
                // Streak Card
                StreakCard()
                
                // Recommended Lessons
                RecommendedLessonsSection()
                
                // Recent Achievements
                if !viewModel.recentAchievements.isEmpty {
                    RecentAchievementsSection()
                }
                
                Spacer(minLength: 100) // Space for tab bar
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .refreshable {
            viewModel.refreshData()
        }
        .onAppear {
            viewModel.userProgressService = userProgressService
            viewModel.lessonService = lessonService
        }
        .sheet(isPresented: $showQuizView) {
            if let lesson = selectedLesson {
                QuizView(lesson: lesson)
                    .environmentObject(userProgressService)
                    .environmentObject(lessonService)
            }
        }
    }
    
    @ViewBuilder
    private func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.greeting)
                        .font(.title2)
                        
                        .foregroundColor(.white.opacity(0.8))
                    
                    if let user = userProgressService.currentUser {
                        Text(user.name)
                            .font(.largeTitle)
                            
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Profile image placeholder
                ZStack {
                    Circle()
                        .fill(Color(hex: "F8C029"))
                        .frame(width: 50, height: 50)
                    
                    Text(userProgressService.currentUser?.name.prefix(1).uppercased() ?? "U")
                        .font(.title2)
                        
                        .foregroundColor(Color(hex: "152842"))
                }
            }
        }
    }
    
    @ViewBuilder
    private func DailyProgressCard() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Today's Progress")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.todayXP) XP earned")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text("\(Int(viewModel.dailyGoalProgress * 100))%")
                    .font(.title2)
                    
                    .foregroundColor(Color(hex: "F8C029"))
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "F8C029"))
                        .frame(width: geometry.size.width * viewModel.dailyGoalProgress, height: 8)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.dailyGoalProgress)
                }
            }
            .frame(height: 8)
            
            if let user = userProgressService.currentUser {
                Text("Goal: \(user.learningGoal.dailyGoalXP) XP")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func StreakCard() -> some View {
        HStack(spacing: 20) {
            // Streak flame icon
            ZStack {
                Circle()
                    .fill(Color(hex: "F8C029").opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "F8C029"))
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Current Streak")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(alignment: .bottom, spacing: 5) {
                    Text("\(viewModel.streakCount)")
                        .font(.title)
                        
                        .foregroundColor(Color(hex: "F8C029"))
                    
                    Text("days")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                if let user = userProgressService.currentUser, user.longestStreak > viewModel.streakCount {
                    Text("Best: \(user.longestStreak) days")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func RecommendedLessonsSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Continue Learning")
                    .font(.title2)
                    
                    .foregroundColor(.white)
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(Color(hex: "F8C029"))
                }
            }
            
            if viewModel.recommendedLessons.isEmpty && !viewModel.isLoading {
                EmptyLessonsView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.recommendedLessons) { lesson in
                        LessonCard(lesson: lesson) {
                            selectedLesson = lesson
                            showQuizView = true
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func RecentAchievementsSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Achievements")
                .font(.title2)
                
                .foregroundColor(.white)
            
            LazyVStack(spacing: 10) {
                ForEach(viewModel.recentAchievements) { achievement in
                    HomeAchievementCard(achievement: achievement)
                }
            }
        }
    }
}

struct LessonCard: View {
    let lesson: Lesson
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Language flag or icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "0954A6").opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text(flagForLanguage(lesson.language))
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                    
                    HStack(spacing: 15) {
                        Label("\(lesson.estimatedDuration) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Label("\(lesson.xpReward) XP", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(Color(hex: "F8C029"))
                        
                        DifficultyBadge(difficulty: lesson.difficulty)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    private func flagForLanguage(_ language: String) -> String {
        switch language {
        case "Spanish": return "🇪🇸"
        case "English": return "🇺🇸"
        case "French": return "🇫🇷"
        case "German": return "🇩🇪"
        case "Italian": return "🇮🇹"
        case "Portuguese": return "🇵🇹"
        case "Japanese": return "🇯🇵"
        case "Korean": return "🇰🇷"
        case "Chinese": return "🇨🇳"
        default: return "🌍"
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption)
            
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: difficulty.color).opacity(0.3))
            )
    }
}

struct HomeAchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color(hex: achievement.category.color).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: achievement.iconName)
                    .foregroundColor(Color(hex: achievement.category.color))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text("+\(achievement.xpReward) XP")
                .font(.caption)
                
                .foregroundColor(Color(hex: "F8C029"))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: achievement.category.color).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct EmptyLessonsView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No lessons available")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Check back later for new content!")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(UserProgressService())
        .environmentObject(LessonService())
}
