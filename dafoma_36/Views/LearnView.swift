//
//  LearnView.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct LearnView: View {
    @EnvironmentObject var userProgressService: UserProgressService
    @EnvironmentObject var lessonService: LessonService
    @State private var selectedModule: LearningModule?
    @State private var showQuizView = false
    @State private var selectedLesson: Lesson?
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    HeaderView()
                    
                    // Search bar
                    SearchBar()
                    
                    // Learning modules
                    ModulesSection()
                    
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
            .sheet(isPresented: $showQuizView) {
                if let lesson = selectedLesson {
                    QuizView(lesson: lesson)
                        .environmentObject(userProgressService)
                        .environmentObject(lessonService)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private func HeaderView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Learn")
                    .font(.largeTitle)
                    
                    .foregroundColor(.white)
                
                Text("Choose your learning path")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func SearchBar() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Search lessons...", text: $searchText)
                .foregroundColor(.white)
                .font(.body)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func ModulesSection() -> some View {
        LazyVStack(spacing: 20) {
            ForEach(filteredModules) { module in
                ModuleCard(module: module) { lesson in
                    selectedLesson = lesson
                    showQuizView = true
                }
            }
        }
    }
    
    private var filteredModules: [LearningModule] {
        if searchText.isEmpty {
            return lessonService.availableModules
        } else {
            return lessonService.availableModules.filter { module in
                module.title.localizedCaseInsensitiveContains(searchText) ||
                module.language.localizedCaseInsensitiveContains(searchText) ||
                module.lessons.contains { lesson in
                    lesson.title.localizedCaseInsensitiveContains(searchText) ||
                    lesson.description.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
}

struct ModuleCard: View {
    let module: LearningModule
    let onLessonTap: (Lesson) -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Module header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 15) {
                    // Module icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: module.color).opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: module.iconName)
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: module.color))
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(module.title)
                            .font(.title2)
                            
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        Text(module.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                        
                        HStack(spacing: 15) {
                            Text(module.language)
                                .font(.caption)
                                
                                .foregroundColor(Color(hex: module.color))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(hex: module.color).opacity(0.2))
                                )
                            
                            Text("\(module.lessons.count) lessons")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            if module.completionPercentage > 0 {
                                Text("\(Int(module.completionPercentage))% complete")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "F8C029"))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
                .padding(20)
            }
            
            // Lessons list (expandable)
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(module.lessons.enumerated()), id: \.element.id) { index, lesson in
                        LessonRowView(
                            lesson: lesson,
                            isLocked: lesson.isLocked,
                            isCompleted: isLessonCompleted(lesson.id)
                        ) {
                            if !lesson.isLocked {
                                onLessonTap(lesson)
                            }
                        }
                        
                        if index < module.lessons.count - 1 {
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .background(Color.white.opacity(0.05))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
    
    private func isLessonCompleted(_ lessonId: String) -> Bool {
        return UserProgressService().currentUser?.completedLessons.contains(lessonId) ?? false
    }
}

struct LessonRowView: View {
    let lesson: Lesson
    let isLocked: Bool
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Status icon
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: statusIcon)
                        .foregroundColor(statusColor)
                        .font(.system(size: 16))
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(isLocked ? .white.opacity(0.5) : .white)
                        .multilineTextAlignment(.leading)
                    
                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundColor(isLocked ? .white.opacity(0.3) : .white.opacity(0.7))
                        .lineLimit(2)
                    
                    HStack(spacing: 15) {
                        Label("\(lesson.estimatedDuration) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(isLocked ? .white.opacity(0.3) : .white.opacity(0.6))
                        
                        Label("\(lesson.xpReward) XP", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(isLocked ? .white.opacity(0.3) : Color(hex: "F8C029"))
                        
                        DifficultyBadge(difficulty: lesson.difficulty)
                            .opacity(isLocked ? 0.5 : 1.0)
                    }
                }
                
                Spacer()
                
                if !isLocked {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(Color(hex: "F8C029"))
                        .font(.title2)
                }
            }
            .padding(20)
            .background(Color.clear)
        }
        .disabled(isLocked)
    }
    
    private var statusColor: Color {
        if isLocked {
            return .gray
        } else if isCompleted {
            return .green
        } else {
            return Color(hex: "F8C029")
        }
    }
    
    private var statusIcon: String {
        if isLocked {
            return "lock.fill"
        } else if isCompleted {
            return "checkmark"
        } else {
            return "play.fill"
        }
    }
}

#Preview {
    LearnView()
        .environmentObject(UserProgressService())
        .environmentObject(LessonService())
}
