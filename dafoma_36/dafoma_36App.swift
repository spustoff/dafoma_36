//
//  LexiQuestApp.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

@main
struct LexiQuestApp: App {
    @StateObject private var userProgressService = UserProgressService()
    
    var body: some Scene {
        WindowGroup {
            if userProgressService.hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(userProgressService)
            } else {
                OnboardingView()
                    .environmentObject(userProgressService)
            }
        }
    }
}
