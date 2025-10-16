import SwiftUI

struct ChatView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var presentationViewModel: PresentationViewModel
    @State private var showingPresentation = false
    @State private var selectedPresentation: PresentationData?
    
    var body: some View {
        NavigationView {
            VStack {
                // Список сообщений
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatViewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if chatViewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Создаю презентацию...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chatViewModel.messages.count) { _ in
                        if let lastMessage = chatViewModel.messages.last {
                            withAnimation(.easeOut(duration: 0.5)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Поле ввода
                HStack {
                    TextField("Опишите презентацию, которую хотите создать...", text: $chatViewModel.inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            chatViewModel.sendMessage()
                        }
                    
                    Button(action: {
                        chatViewModel.sendMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(chatViewModel.inputText.isEmpty ? Color.gray : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(chatViewModel.inputText.isEmpty || chatViewModel.isLoading)
                }
                .padding()
            }
            .navigationTitle("AI Презентации")
            .sheet(isPresented: $showingPresentation) {
                if let presentation = selectedPresentation {
                    PresentationView(presentation: presentation)
                }
            }
            .onChange(of: chatViewModel.messages) { messages in
                // Проверяем, есть ли новые презентации в сообщениях
                for message in messages {
                    if let presentationData = message.presentationData {
                        presentationViewModel.addPresentation(presentationData)
                        selectedPresentation = presentationData
                        showingPresentation = true
                    }
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .cornerRadius(4, corners: .bottomTrailing)
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                        .cornerRadius(4, corners: .bottomLeading)
                    
                    if let presentationData = message.presentationData {
                        PresentationPreviewCard(presentation: presentationData)
                    }
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
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

struct PresentationPreviewCard: View {
    let presentation: PresentationData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.blue)
                Text("Новая презентация")
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
            }
            
            Text(presentation.title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Label("\(presentation.slides.count) слайдов", systemImage: "rectangle.stack")
                Spacer()
                Label("\(presentation.duration) мин", systemImage: "clock")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Text(presentation.theme)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(4)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ChatView()
        .environmentObject(ChatViewModel())
        .environmentObject(PresentationViewModel())
}