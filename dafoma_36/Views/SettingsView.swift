//
//  SettingsView.swift
//  LexiQuest Nacional
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userProgressService: UserProgressService
    @Environment(\.dismiss) private var dismiss
    
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var dailyReminderEnabled = true
    @State private var reminderTime = Date()
    @State private var darkModeEnabled = false
    @State private var showDeleteAlert = false
    
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
                        // Notifications Section
                        NotificationsSection()
                        
                        // App Preferences Section
                        AppPreferencesSection()
                        
                        // Account Section
                        AccountSection()
                        
                        // About Section
                        AboutSection()
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
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
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                userProgressService.deleteAccount()
                dismiss()
            }
        } message: {
            Text("This will permanently delete your account and all progress. This action cannot be undone.")
        }
    }
    
    @ViewBuilder
    private func NotificationsSection() -> some View {
        SettingsSection(title: "Notifications") {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "Push Notifications",
                    description: "Get notified about your progress and reminders",
                    isOn: $notificationsEnabled
                )
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsToggleRow(
                    title: "Sound Effects",
                    description: "Play sounds for correct answers and achievements",
                    isOn: $soundEnabled
                )
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsToggleRow(
                    title: "Daily Reminders",
                    description: "Remind me to practice every day",
                    isOn: $dailyReminderEnabled
                )
                
                if dailyReminderEnabled {
                    Divider().background(Color.white.opacity(0.1))
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reminder Time")
                                .font(.body)
                                .foregroundColor(.white)
                            
                            Text("When to send daily practice reminders")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .colorScheme(.dark)
                    }
                    .padding()
                }
            }
        }
    }
    
    @ViewBuilder
    private func AppPreferencesSection() -> some View {
        SettingsSection(title: "App Preferences") {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "Dark Mode",
                    description: "Use dark theme throughout the app",
                    isOn: $darkModeEnabled
                )
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsNavigationRow(
                    title: "Language",
                    value: "English",
                    description: "App display language"
                ) {
                    // Handle language selection
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsNavigationRow(
                    title: "Data Usage",
                    description: "Manage offline content and data usage"
                ) {
                    // Handle data usage settings
                }
            }
        }
    }
    
    @ViewBuilder
    private func AccountSection() -> some View {
        SettingsSection(title: "Account") {
            VStack(spacing: 0) {
                SettingsNavigationRow(
                    title: "Export Data",
                    description: "Download your learning progress and data"
                ) {
                    // Handle data export
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsNavigationRow(
                    title: "Reset Progress",
                    description: "Clear all learning progress (keeps account)",
                    titleColor: .orange
                ) {
                    // Handle progress reset
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsNavigationRow(
                    title: "Delete Account",
                    description: "Permanently delete your account and all data",
                    titleColor: .red
                ) {
                    showDeleteAlert = true
                }
            }
        }
    }
    
    @ViewBuilder
    private func AboutSection() -> some View {
        SettingsSection(title: "About") {
            VStack(spacing: 0) {
                SettingsNavigationRow(
                    title: "Privacy Policy",
                    description: "How we handle your personal information"
                ) {
                    // Handle privacy policy
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsNavigationRow(
                    title: "Terms of Service",
                    description: "Terms and conditions of using LexiQuest"
                ) {
                    // Handle terms of service
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsNavigationRow(
                    title: "Contact Support",
                    description: "Get help and send feedback"
                ) {
                    // Handle contact support
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsInfoRow(
                    title: "Version",
                    value: "1.0.0"
                )
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
}

struct SettingsToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "F8C029")))
        }
        .padding()
    }
}

struct SettingsNavigationRow: View {
    let title: String
    let value: String?
    let description: String
    let titleColor: Color
    let action: () -> Void
    
    init(title: String, value: String? = nil, description: String, titleColor: Color = .white, action: @escaping () -> Void) {
        self.title = title
        self.value = value
        self.description = description
        self.titleColor = titleColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(titleColor)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 12))
            }
            .padding()
        }
    }
}

struct SettingsInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserProgressService())
}
