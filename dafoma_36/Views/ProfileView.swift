//
//  ProfileView.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userProgressService: UserProgressService
    @State private var showEditProfile = false
    @State private var showDeleteAlert = false
    @State private var showSettings = false
    @State private var showAchievements = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Profile Header
                ProfileHeader()
                
                // Stats Cards
                StatsSection()
                
                // Quick Actions
                QuickActionsSection()
                
                // Settings Menu
                SettingsSection()
                
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
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(userProgressService)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(userProgressService)
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
                .environmentObject(userProgressService)
        }
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                userProgressService.deleteAccount()
            }
        } message: {
            Text("This will permanently delete your account and all progress. This action cannot be undone.")
        }
    }
    
    @ViewBuilder
    private func ProfileHeader() -> some View {
        VStack(spacing: 20) {
            // Profile image
            ZStack {
                Circle()
                    .fill(Color(hex: "F8C029"))
                    .frame(width: 100, height: 100)
                
                Text(userProgressService.currentUser?.name.prefix(1).uppercased() ?? "U")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(hex: "152842"))
            }
            
            VStack(spacing: 8) {
                Text(userProgressService.currentUser?.name ?? "Unknown User")
                    .font(.title)
                    
                    .foregroundColor(.white)
                
                Text(userProgressService.currentUser?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                // Level badge
                HStack(spacing: 5) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(Color(hex: "F8C029"))
                    
                    Text("Level \(userProgressService.currentUser?.currentLevel ?? 1)")
                        .font(.headline)
                        
                        .foregroundColor(Color(hex: "F8C029"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(hex: "F8C029").opacity(0.2))
                )
            }
            
            Button("Edit Profile") {
                showEditProfile = true
            }
            .font(.subheadline)
            .foregroundColor(Color(hex: "F8C029"))
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "F8C029"), lineWidth: 1)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private func StatsSection() -> some View {
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
                title: "Lessons Completed",
                value: "\(userProgressService.currentUser?.completedLessons.count ?? 0)",
                icon: "book.fill",
                color: Color(hex: "0954A6")
            )
            
            StatCard(
                title: "Current Streak",
                value: "\(userProgressService.currentUser?.currentStreak ?? 0) days",
                icon: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: "Achievements",
                value: "\(userProgressService.achievements.filter { $0.isUnlocked }.count)",
                icon: "trophy.fill",
                color: .green
            )
        }
    }
    
    @ViewBuilder
    private func QuickActionsSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Actions")
                .font(.title2)
                
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                QuickActionButton(
                    title: "View Achievements",
                    icon: "trophy.fill",
                    color: .green
                ) {
                    showAchievements = true
                }
                
                QuickActionButton(
                    title: "Learning Goals",
                    icon: "target",
                    color: Color(hex: "0954A6")
                ) {
                    showEditProfile = true
                }
                
                QuickActionButton(
                    title: "App Settings",
                    icon: "gearshape.fill",
                    color: .gray
                ) {
                    showSettings = true
                }
            }
        }
    }
    
    @ViewBuilder
    private func SettingsSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Account")
                .font(.title2)
                
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                SettingsRow(
                    title: "Delete Account",
                    icon: "trash.fill",
                    titleColor: .red,
                    iconColor: .red,
                    showChevron: false
                ) {
                    showDeleteAlert = true
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 18))
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 14))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let titleColor: Color
    let iconColor: Color
    let showChevron: Bool
    let action: () -> Void
    
    init(title: String, icon: String, titleColor: Color = .white, iconColor: Color = .white.opacity(0.7), showChevron: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.titleColor = titleColor
        self.iconColor = iconColor
        self.showChevron = showChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 16))
                    .frame(width: 20)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(titleColor)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 12))
                }
            }
            .padding()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserProgressService())
}
