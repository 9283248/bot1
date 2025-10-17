import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: PresentationViewModel
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Фоновый градиент
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.1, blue: 0.3),
                    Color(red: 0.1, green: 0.2, blue: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Заголовок чата с стеклянным эффектом
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Презентация")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Создавайте презентации через чат")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.generateNewPresentation(from: "Создай новую презентацию")
                    }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "plus")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 0))
                .overlay(
                    Rectangle()
                        .fill(.white.opacity(0.1))
                        .frame(height: 1),
                    alignment: .bottom
                )
            
                // Список сообщений
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if viewModel.isLoading {
                                HStack {
                                    Spacer()
                                    LoadingIndicator()
                                    Spacer()
                                }
                                .padding(.vertical, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            
                // Поле ввода с стеклянным эффектом
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                            
                            TextField("Напишите что создать или изменить...", text: $messageText)
                                .focused($isTextFieldFocused)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .foregroundColor(.white)
                                .background(Color.clear)
                        }
                        .frame(height: 48)
                        
                        Button(action: sendMessage) {
                            ZStack {
                                Circle()
                                    .fill(messageText.isEmpty ? .gray.opacity(0.3) : .blue)
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(messageText.isEmpty || viewModel.isLoading)
                        .scaleEffect(messageText.isEmpty ? 0.9 : 1.0)
                        .animation(.spring(response: 0.3), value: messageText.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 0))
                .overlay(
                    Rectangle()
                        .fill(.white.opacity(0.1))
                        .frame(height: 1),
                    alignment: .top
                )
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        viewModel.sendMessage(messageText)
        messageText = ""
    }
}

struct MessageBubble: View {
    let message: AIMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.blue)
                                
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.white.opacity(0.1))
                                    .blendMode(.overlay)
                            }
                        )
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.purple)
                        }
                        
                        Text(message.content)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                    
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.white.opacity(0.1))
                                        .blendMode(.overlay)
                                }
                            )
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.leading, 44)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                
                Spacer()
            }
        }
    }
}

struct LoadingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(.white.opacity(0.8))
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.1))
                    .blendMode(.overlay)
            }
        )
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ChatView(viewModel: PresentationViewModel())
}