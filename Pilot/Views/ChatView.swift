//
//  ChatView.swift
//  PILOT
//
//  Chat conversation view - ported from app/chat.tsx
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let entry: DailyEntry

    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isSending = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Context Card
                    ContextCard(entry: entry)
                        .padding()

                    Divider()
                        .background(AppTheme.Colors.textTertiary.opacity(0.3))

                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: AppTheme.Spacing.md) {
                                ForEach(messages) { message in
                                    ChatBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) { _, _ in
                            if let lastMessage = messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }

                    // Input
                    MessageInput(
                        text: $messageText,
                        isSending: isSending,
                        canSend: !appState.profile.isPro && appState.profile.chatCredits <= 0,
                        onSend: sendMessage
                    )
                }
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadMessages()
            }
        }
    }

    private func loadMessages() {
        if let thread = appState.getChatThread(forDate: entry.date) {
            messages = thread.messages
        }
    }

    private func sendMessage() {
        guard !messageText.isEmpty else { return }

        let userMessage = messageText
        messageText = ""
        isSending = true

        // Add user message immediately
        messages.append(ChatMessage(role: .user, content: userMessage))

        Task {
            if let response = await appState.sendChatMessage(userMessage) {
                messages.append(ChatMessage(role: .assistant, content: response))
            }
            isSending = false
        }
    }
}

// MARK: - Context Card

struct ContextCard: View {
    let entry: DailyEntry

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text(entry.mood.emoji)
                Text(entry.mood.displayName)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(Color(hex: entry.mood.color))
            }

            Text(entry.task)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.Radius.md)
    }
}

// MARK: - Chat Bubble

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(
                        message.role == .user
                            ? .white
                            : AppTheme.Colors.textPrimary
                    )
                    .padding(AppTheme.Spacing.md)
                    .background(
                        message.role == .user
                            ? AppTheme.Colors.primary
                            : AppTheme.Colors.cardBackground
                    )
                    .cornerRadius(AppTheme.Radius.md)

                Text(formatTime(message.timestamp))
                    .font(AppTheme.Typography.small)
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }

            if message.role == .assistant {
                Spacer()
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Message Input

struct MessageInput: View {
    @Binding var text: String
    let isSending: Bool
    let canSend: Bool
    let onSend: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(AppTheme.Colors.textTertiary.opacity(0.3))

            HStack(spacing: AppTheme.Spacing.md) {
                TextField("Type a message...", text: $text)
                    .textFieldStyle(.plain)
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(AppTheme.Radius.md)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .disabled(canSend)

                Button(action: onSend) {
                    if isSending {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
                .disabled(text.isEmpty || isSending || canSend)
                .opacity(text.isEmpty || isSending || canSend ? 0.5 : 1.0)
            }
            .padding()
            .background(AppTheme.Colors.background)
        }
    }
}

#Preview {
    ChatView(entry: DailyEntry(
        date: "2025-10-23",
        mood: .hopeful,
        note: nil,
        task: "Organize workspace",
        reflection: "You're feeling great!",
        completed: false
    ))
    .environmentObject(AppState())
}
