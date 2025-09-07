//
//  AchievementsView.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var userProgressService: UserProgressService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: AchievementCategory? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "525152"),
                        Color(hex: "152842")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header stats
                        AchievementStatsView()
                        
                        // Category filter
                        CategoryFilterView()
                        
                        // Achievements grid
                        AchievementsGrid()
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "F8C029"))
                }
            }
        }
    }
    
    @ViewBuilder
    private func AchievementStatsView() -> some View {
        let unlockedCount = userProgressService.achievements.filter { $0.isUnlocked }.count
        let totalCount = userProgressService.achievements.count
        let progress = totalCount > 0 ? Double(unlockedCount) / Double(totalCount) : 0.0
        
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Progress")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(unlockedCount) of \(totalCount)")
                        .font(.title)
                        
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color(hex: "F8C029"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: progress)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.headline)
                        
                        .foregroundColor(Color(hex: "F8C029"))
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "F8C029"))
                        .frame(width: geometry.size.width * progress, height: 12)
                        .animation(.easeInOut(duration: 1.0), value: progress)
                }
            }
            .frame(height: 12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private func CategoryFilterView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryButton(category: nil, title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        title: category.rawValue,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private func AchievementsGrid() -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            ForEach(filteredAchievements, id: \.id) { achievement in
                AchievementCard(achievement: achievement)
            }
        }
    }
    
    private var filteredAchievements: [Achievement] {
        let achievements = userProgressService.achievements
        
        if let selectedCategory = selectedCategory {
            return achievements.filter { $0.category == selectedCategory }
        }
        
        return achievements
    }
}

struct CategoryButton: View {
    let category: AchievementCategory?
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                
                .foregroundColor(isSelected ? Color(hex: "152842") : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(hex: "F8C029") : Color.white.opacity(0.1))
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @State private var showDetails = false
    
    var body: some View {
        Button(action: {
            showDetails = true
        }) {
            VStack(spacing: 15) {
                // Icon and status
                ZStack {
                    Circle()
                        .fill(
                            achievement.isUnlocked ?
                            Color(hex: achievement.category.color).opacity(0.2) :
                            Color.white.opacity(0.1)
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: achievement.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(
                            achievement.isUnlocked ?
                            Color(hex: achievement.category.color) :
                            .white.opacity(0.5)
                        )
                    
                    if achievement.isUnlocked {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 20, y: -20)
                    }
                }
                
                VStack(spacing: 5) {
                    Text(achievement.title)
                        .font(.headline)
                        .foregroundColor(achievement.isUnlocked ? .white : .white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(achievement.description)
                        .font(.caption)
                        .foregroundColor(achievement.isUnlocked ? .white.opacity(0.8) : .white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                // Progress bar for locked achievements
                if !achievement.isUnlocked && achievement.progress > 0 {
                    VStack(spacing: 5) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 6)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(hex: achievement.category.color))
                                    .frame(width: geometry.size.width * achievement.progress, height: 6)
                            }
                        }
                        .frame(height: 6)
                        
                        Text("\(Int(achievement.progress * 100))%")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // XP reward
                Text("+\(achievement.xpReward) XP")
                    .font(.caption)
                    
                    .foregroundColor(achievement.isUnlocked ? Color(hex: "F8C029") : .white.opacity(0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(achievement.isUnlocked ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                achievement.isUnlocked ?
                                Color(hex: achievement.category.color).opacity(0.3) :
                                Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
        }
        .scaleEffect(achievement.isUnlocked ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: achievement.isUnlocked)
        .sheet(isPresented: $showDetails) {
            AchievementDetailView(achievement: achievement)
        }
    }
}

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "525152"),
                        Color(hex: "152842")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Large icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: achievement.category.color).opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: achievement.iconName)
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: achievement.category.color))
                        
                        if achievement.isUnlocked {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 40, y: -40)
                        }
                    }
                    
                    VStack(spacing: 15) {
                        Text(achievement.title)
                            .font(.title)
                            
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(achievement.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Text(achievement.requirement.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Progress or completion info
                    VStack(spacing: 15) {
                        if achievement.isUnlocked {
                            if let unlockedDate = achievement.unlockedDate {
                                Text("Unlocked on \(unlockedDate, style: .date)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            Text("🎉 Achievement Unlocked!")
                                .font(.headline)
                                .foregroundColor(Color(hex: "F8C029"))
                        } else {
                            VStack(spacing: 10) {
                                Text("Progress: \(Int(achievement.progress * 100))%")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white.opacity(0.2))
                                            .frame(height: 12)
                                        
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hex: achievement.category.color))
                                            .frame(width: geometry.size.width * achievement.progress, height: 12)
                                    }
                                }
                                .frame(height: 12)
                            }
                        }
                        
                        Text("Reward: +\(achievement.xpReward) XP")
                            .font(.headline)
                            .foregroundColor(Color(hex: "F8C029"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle(achievement.category.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "F8C029"))
                }
            }
        }
    }
}

#Preview {
    AchievementsView()
        .environmentObject(UserProgressService())
}
