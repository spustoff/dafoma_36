//
//  MainTabView.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userProgressService: UserProgressService
    @StateObject private var lessonService = LessonService()
    @State private var selectedTab: Tab = .home
    
    enum Tab: CaseIterable {
        case home, learn, progress, profile
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .learn: return "Learn"
            case .progress: return "Progress"
            case .profile: return "Profile"
            }
        }
        
        var iconName: String {
            switch self {
            case .home: return "house"
            case .learn: return "book"
            case .progress: return "chart.bar"
            case .profile: return "person"
            }
        }
        
        var selectedIconName: String {
            switch self {
            case .home: return "house.fill"
            case .learn: return "book.fill"
            case .progress: return "chart.bar.fill"
            case .profile: return "person.fill"
            }
        }
    }
    
    var body: some View {
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
            
            VStack(spacing: 0) {
                // Content
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                            .environmentObject(userProgressService)
                            .environmentObject(lessonService)
                    case .learn:
                        LearnView()
                            .environmentObject(userProgressService)
                            .environmentObject(lessonService)
                    case .progress:
                        ProgressView()
                            .environmentObject(userProgressService)
                    case .profile:
                        ProfileView()
                            .environmentObject(userProgressService)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    
    var body: some View {
        HStack {
            ForEach(MainTabView.Tab.allCases, id: \.self) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    selectedTab = tab
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.black.opacity(0.3))
                .blur(radius: 10)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct TabBarItem: View {
    let tab: MainTabView.Tab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.selectedIconName : tab.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color(hex: "F8C029") : .white.opacity(0.6))
                
                Text(tab.title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? Color(hex: "F8C029") : .white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color(hex: "F8C029").opacity(0.2) : Color.clear)
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserProgressService())
}
