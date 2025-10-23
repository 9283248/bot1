import Foundation
import SwiftUI
import Combine

@MainActor
class PresentationViewModel: ObservableObject {
    @Published var currentPresentation: Presentation?
    @Published var messages: [AIMessage] = []
    @Published var isLoading = false
    @Published var selectedElementId: UUID?
    @Published var isPresentationMode = false
    @Published var currentSlideIndex = 0
    
    private let aiService: AIServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(aiService: AIServiceProtocol = OpenAIService()) {
        self.aiService = aiService
        setupInitialPresentation()
    }
    
    private func setupInitialPresentation() {
        currentPresentation = Presentation(title: "Новая Презентация")
        addWelcomeMessage()
    }
    
    private func addWelcomeMessage() {
        let welcomeMessage = AIMessage(
            content: "Привет! Я AI-ассистент для создания презентаций. Скажите, какую презентацию вы хотели бы создать? Например: 'Создай бизнес-презентацию о продажах' или 'Сделай образовательную презентацию о математике'.",
            isUser: false
        )
        messages.append(welcomeMessage)
    }
    
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = AIMessage(content: text, isUser: true)
        messages.append(userMessage)
        
        Task {
            await processUserMessage(text)
        }
    }
    
    private func processUserMessage(_ text: String) async {
        isLoading = true
        
        do {
            let aiMessage = try await aiService.processMessage(text, currentPresentation: currentPresentation ?? Presentation(title: "Новая Презентация"))
            
            // Применяем изменения к презентации
            if let changes = aiMessage.presentationChanges {
                applyPresentationChanges(changes)
            }
            
            messages.append(aiMessage)
            
        } catch {
            let errorMessage = AIMessage(
                content: "Извините, произошла ошибка при обработке вашего запроса. Попробуйте еще раз.",
                isUser: false
            )
            messages.append(errorMessage)
        }
        
        isLoading = false
    }
    
    private func applyPresentationChanges(_ changes: PresentationChanges) {
        guard var presentation = currentPresentation else { return }
        
        // Добавляем новые слайды
        if let newSlides = changes.newSlides {
            presentation.slides.append(contentsOf: newSlides)
        }
        
        // Модифицируем существующие слайды
        if let modifiedSlides = changes.modifiedSlides {
            for modifiedSlide in modifiedSlides {
                if let index = presentation.slides.firstIndex(where: { $0.id == modifiedSlide.id }) {
                    presentation.slides[index] = modifiedSlide
                }
            }
        }
        
        // Удаляем слайды
        if let deletedIds = changes.deletedSlideIds {
            presentation.slides.removeAll { deletedIds.contains($0.id) }
        }
        
        // Изменяем тему
        if let newTheme = changes.themeChange {
            presentation.theme = newTheme
        }
        
        // Выбираем элемент
        if let elementId = changes.selectedElementId {
            selectedElementId = elementId
        }
        
        // Применяем модификации элементов
        if let modification = changes.elementModifications {
            applyElementModification(modification)
        }
        
        presentation.modifiedAt = Date()
        currentPresentation = presentation
    }
    
    private func applyElementModification(_ modification: ElementModification) {
        guard var presentation = currentPresentation else { return }
        
        for slideIndex in 0..<presentation.slides.count {
            for elementIndex in 0..<presentation.slides[slideIndex].elements.count {
                if presentation.slides[slideIndex].elements[elementIndex].id == modification.elementId {
                    var element = presentation.slides[slideIndex].elements[elementIndex]
                    
                    if let newText = modification.newText, var textElement = element as? TextElement {
                        textElement.text = newText
                        presentation.slides[slideIndex].elements[elementIndex] = textElement
                    }
                    
                    if let newPosition = modification.newPosition {
                        element.position = newPosition
                    }
                    
                    if let newSize = modification.newSize {
                        element.size = newSize
                    }
                    
                    if let newRotation = modification.newRotation {
                        element.rotation = newRotation
                    }
                    
                    if let newZIndex = modification.newZIndex {
                        element.zIndex = newZIndex
                    }
                    
                    presentation.slides[slideIndex].elements[elementIndex] = element
                    break
                }
            }
        }
        
        currentPresentation = presentation
    }
    
    func selectElement(_ elementId: UUID) {
        selectedElementId = elementId
    }
    
    func deselectElement() {
        selectedElementId = nil
    }
    
    func startPresentation() {
        isPresentationMode = true
        currentSlideIndex = 0
    }
    
    func endPresentation() {
        isPresentationMode = false
        currentSlideIndex = 0
    }
    
    func nextSlide() {
        guard let presentation = currentPresentation else { return }
        if currentSlideIndex < presentation.slides.count - 1 {
            currentSlideIndex += 1
        }
    }
    
    func previousSlide() {
        if currentSlideIndex > 0 {
            currentSlideIndex -= 1
        }
    }
    
    func generateNewPresentation(from prompt: String) {
        Task {
            isLoading = true
            
            do {
                let newPresentation = try await aiService.generatePresentation(from: prompt)
                currentPresentation = newPresentation
                
                let successMessage = AIMessage(
                    content: "Отлично! Я создал новую презентацию на основе вашего запроса: '\(prompt)'. Теперь вы можете попросить меня изменить любой элемент или добавить новые слайды.",
                    isUser: false
                )
                messages.append(successMessage)
                
            } catch {
                let errorMessage = AIMessage(
                    content: "Извините, не удалось создать презентацию. Попробуйте еще раз с другим описанием.",
                    isUser: false
                )
                messages.append(errorMessage)
            }
            
            isLoading = false
        }
    }
}