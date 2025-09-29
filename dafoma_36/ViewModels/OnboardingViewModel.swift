//
//  OnboardingViewModel.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var selectedLanguages: Set<String> = []
    @Published var selectedGoal: LearningGoal = .regular
    @Published var isValid: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    var userProgressService: UserProgressService
    private var cancellables = Set<AnyCancellable>()
    
    let totalSteps = 3
    let availableLanguages = ["Spanish", "English", "French", "German", "Italian", "Portuguese", "Japanese", "Korean", "Chinese"]
    
    init(userProgressService: UserProgressService) {
        self.userProgressService = userProgressService
        setupValidation()
    }
    
    private func setupValidation() {
        // Validate current step
        Publishers.CombineLatest(
            $currentStep,
            $selectedLanguages
        )
        .map { step, languages in
            switch step {
            case 0: // Welcome step
                return true
            case 1: // Language selection
                return !languages.isEmpty
            case 2: // Goal selection
                return true
            default:
                return false
            }
        }
        .assign(to: &$isValid)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func nextStep() {
        guard isValid else {
            showError(message: "Please complete all required fields")
            return
        }
        
        if currentStep < totalSteps - 1 {
            currentStep += 1
        } else {
            completeOnboarding()
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func selectLanguage(_ language: String) {
        if selectedLanguages.contains(language) {
            selectedLanguages.remove(language)
        } else {
            selectedLanguages.insert(language)
        }
    }
    
    func selectGoal(_ goal: LearningGoal) {
        selectedGoal = goal
    }
    
    private func completeOnboarding() {
        guard !selectedLanguages.isEmpty else {
            showError(message: "Please select at least one language")
            return
        }
        
        userProgressService.createUser(
            name: "User",
            email: "user@example.com",
            preferredLanguages: Array(selectedLanguages),
            learningGoal: selectedGoal
        )
        
        userProgressService.completeOnboarding()
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
        
        // Auto-hide error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.showError = false
        }
    }
}

// MARK: - Step Information
extension OnboardingViewModel {
    var currentStepTitle: String {
        switch currentStep {
        case 0: return "Welcome to Lexi Nova!"
        case 1: return "Choose your languages"
        case 2: return "Set your goal"
        default: return ""
        }
    }
    
    var currentStepDescription: String {
        switch currentStep {
        case 0: return "Your journey to language mastery starts here. Let's get you set up!"
        case 1: return "Select the languages you want to learn. You can add more later!"
        case 2: return "How much time do you want to spend learning each day?"
        default: return ""
        }
    }
    
    var progressPercentage: Double {
        return Double(currentStep) / Double(totalSteps - 1)
    }
    
    var isFirstStep: Bool {
        return currentStep == 0
    }
    
    var isLastStep: Bool {
        return currentStep == totalSteps - 1
    }
    
    var nextButtonTitle: String {
        return isLastStep ? "Get Started!" : "Continue"
    }
}
