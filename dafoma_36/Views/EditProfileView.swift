//
//  EditProfileView.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var userProgressService: UserProgressService
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var selectedLanguages: Set<String> = []
    @State private var selectedGoal: LearningGoal = .regular
    @State private var showError = false
    @State private var errorMessage = ""
    
    let availableLanguages = ["Spanish", "English", "French", "German", "Italian", "Portuguese", "Japanese", "Korean", "Chinese"]
    
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
                        // Profile Image Section
                        ProfileImageSection()
                        
                        // Basic Info Section
                        BasicInfoSection()
                        
                        // Languages Section
                        LanguagesSection()
                        
                        // Learning Goal Section
                        LearningGoalSection()
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .foregroundColor(Color(hex: "F8C029"))
                    .font(.headline)
                }
            }
        }
        .onAppear {
            loadCurrentData()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    @ViewBuilder
    private func ProfileImageSection() -> some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color(hex: "F8C029"))
                    .frame(width: 100, height: 100)
                
                Text(name.prefix(1).uppercased())
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(hex: "152842"))
            }
        }
    }
    
    @ViewBuilder
    private func BasicInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Basic Information")
                .font(.title2)
                
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                CustomTextField(
                    title: "Name",
                    text: $name,
                    placeholder: "Enter your name"
                )
                
                CustomTextField(
                    title: "Email",
                    text: $email,
                    placeholder: "Enter your email"
                )
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
    
    @ViewBuilder
    private func LanguagesSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Learning Languages")
                .font(.title2)
                
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(availableLanguages, id: \.self) { language in
                    LanguageToggleCard(
                        language: language,
                        isSelected: selectedLanguages.contains(language)
                    ) {
                        toggleLanguage(language)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
    
    @ViewBuilder
    private func LearningGoalSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Learning Goal")
                .font(.title2)
                
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(LearningGoal.allCases, id: \.self) { goal in
                    GoalSelectionCard(
                        goal: goal,
                        isSelected: selectedGoal == goal
                    ) {
                        selectedGoal = goal
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
    
    private func loadCurrentData() {
        guard let user = userProgressService.currentUser else { return }
        
        name = user.name
        email = user.email
        selectedLanguages = Set(user.preferredLanguages)
        selectedGoal = user.learningGoal
    }
    
    private func toggleLanguage(_ language: String) {
        if selectedLanguages.contains(language) {
            selectedLanguages.remove(language)
        } else {
            selectedLanguages.insert(language)
        }
    }
    
    private func saveProfile() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError(message: "Name cannot be empty")
            return
        }
        
        guard isValidEmail(email) else {
            showError(message: "Please enter a valid email address")
            return
        }
        
        guard !selectedLanguages.isEmpty else {
            showError(message: "Please select at least one language")
            return
        }
        
        guard var user = userProgressService.currentUser else { return }
        
        user.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        user.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        user.preferredLanguages = Array(selectedLanguages)
        user.learningGoal = selectedGoal
        
        userProgressService.updateUser(user)
        dismiss()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

struct LanguageToggleCard: View {
    let language: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(flagForLanguage(language))
                    .font(.system(size: 24))
                
                Text(language)
                    .font(.subheadline)
                    
                    .foregroundColor(isSelected ? Color(hex: "152842") : .white)
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? Color(hex: "F8C029") : Color.white.opacity(0.1)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "F8C029") : Color.white.opacity(0.3), lineWidth: 1)
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

struct GoalSelectionCard: View {
    let goal: LearningGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(goal.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? Color(hex: "152842") : .white)
                    
                    Text("\(goal.dailyGoalMinutes) min/day • \(goal.dailyGoalXP) XP goal")
                        .font(.caption)
                        .foregroundColor(isSelected ? Color(hex: "152842").opacity(0.8) : .white.opacity(0.7))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: "152842") : Color.white.opacity(0.5), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "152842"))
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding()
            .background(
                isSelected ? Color(hex: "F8C029") : Color.white.opacity(0.1)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "F8C029") : Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    EditProfileView()
        .environmentObject(UserProgressService())
}
