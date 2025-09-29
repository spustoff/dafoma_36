//
//  OnboardingView.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userProgressService: UserProgressService
    @StateObject private var viewModel: OnboardingViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: OnboardingViewModel(userProgressService: UserProgressService()))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
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
                    // Progress bar
                    if viewModel.currentStep > 0 {
                        ProgressBar(progress: viewModel.progressPercentage)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                    }
                    
                    // Content
                    TabView(selection: $viewModel.currentStep) {
                        WelcomeStepView()
                            .tag(0)
                        
                        LanguageSelectionStepView(viewModel: viewModel)
                            .tag(1)
                        
                        GoalSelectionStepView(viewModel: viewModel)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
                    
                    // Navigation buttons
                    NavigationButtons(viewModel: viewModel)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            viewModel.userProgressService = userProgressService
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App logo/icon
            ZStack {
                Circle()
                    .fill(Color(hex: "F8C029"))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "book.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: "152842"))
            }
            
            VStack(spacing: 15) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Lexi Nova Nacional")
                    .font(.largeTitle)
                    
                    .foregroundColor(.white)
                
                Text("Your journey to language mastery starts here. Let's get you set up!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}


struct LanguageSelectionStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            StepHeader(
                title: viewModel.currentStepTitle,
                description: viewModel.currentStepDescription
            )
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(viewModel.availableLanguages, id: \.self) { language in
                        LanguageCard(
                            language: language,
                            isSelected: viewModel.selectedLanguages.contains(language)
                        ) {
                            viewModel.selectLanguage(language)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
}

struct GoalSelectionStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            StepHeader(
                title: viewModel.currentStepTitle,
                description: viewModel.currentStepDescription
            )
            
            VStack(spacing: 15) {
                ForEach(LearningGoal.allCases, id: \.self) { goal in
                    GoalCard(
                        goal: goal,
                        isSelected: viewModel.selectedGoal == goal
                    ) {
                        viewModel.selectGoal(goal)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Supporting Views

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                Rectangle()
                    .fill(Color(hex: "F8C029"))
                    .frame(width: geometry.size.width * progress, height: 4)
                    .cornerRadius(2)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 4)
    }
}

struct StepHeader: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.title)
                
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct LanguageCard: View {
    let language: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(flagForLanguage(language))
                    .font(.system(size: 30))
                
                Text(language)
                    .font(.headline)
                    .foregroundColor(isSelected ? Color(hex: "152842") : .white)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? Color(hex: "F8C029") : Color.white.opacity(0.1)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "F8C029") : Color.white.opacity(0.3), lineWidth: 2)
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
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

struct GoalCard: View {
    let goal: LearningGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(goal.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? Color(hex: "152842") : .white)
                    
                    Text("\(goal.dailyGoalMinutes) min/day • \(goal.dailyGoalXP) XP goal")
                        .font(.caption)
                        .foregroundColor(isSelected ? Color(hex: "152842").opacity(0.8) : .white.opacity(0.7))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "152842"))
                        .font(.title2)
                }
            }
            .padding()
            .background(
                isSelected ? Color(hex: "F8C029") : Color.white.opacity(0.1)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "F8C029") : Color.white.opacity(0.3), lineWidth: 2)
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct NavigationButtons: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        HStack {
            if !viewModel.isFirstStep {
                Button("Back") {
                    viewModel.previousStep()
                }
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(viewModel.nextButtonTitle) {
                viewModel.nextStep()
            }
            .font(.headline)
            .foregroundColor(Color(hex: "152842"))
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                viewModel.isValid ? Color(hex: "F8C029") : Color.gray.opacity(0.5)
            )
            .cornerRadius(25)
            .disabled(!viewModel.isValid)
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    OnboardingView()
        .environmentObject(UserProgressService())
}
