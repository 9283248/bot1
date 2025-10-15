import Foundation
import SwiftUI

class PresentationViewModel: ObservableObject {
    @Published var presentations: [PresentationData] = []
    @Published var currentPresentation: PresentationData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func addPresentation(_ presentation: PresentationData) {
        presentations.append(presentation)
        currentPresentation = presentation
    }
    
    func updatePresentation(_ presentation: PresentationData) {
        if let index = presentations.firstIndex(where: { $0.title == presentation.title }) {
            presentations[index] = presentation
            currentPresentation = presentation
        }
    }
    
    func deletePresentation(at index: Int) {
        presentations.remove(at: index)
        if presentations.isEmpty {
            currentPresentation = nil
        }
    }
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false
    
    private let aiService = AIService()
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(content: inputText, isUser: true)
        messages.append(userMessage)
        
        let currentInput = inputText
        inputText = ""
        isLoading = true
        
        Task {
            do {
                let response = try await aiService.generatePresentation(prompt: currentInput)
                await MainActor.run {
                    let aiMessage = ChatMessage(
                        content: "Я создал презентацию на основе вашего запроса!",
                        isUser: false,
                        presentationData: response
                    )
                    messages.append(aiMessage)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    let errorMessage = ChatMessage(
                        content: "Извините, произошла ошибка при создании презентации: \(error.localizedDescription)",
                        isUser: false
                    )
                    messages.append(errorMessage)
                    isLoading = false
                }
            }
        }
    }
}