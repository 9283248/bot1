import Foundation
import SwiftUI

// MARK: - AI Message Model
struct AIMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    var presentationChanges: PresentationChanges?
    
    init(content: String, isUser: Bool, presentationChanges: PresentationChanges? = nil) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
        self.presentationChanges = presentationChanges
    }
}

// MARK: - Presentation Changes
struct PresentationChanges: Codable {
    var newSlides: [Slide]?
    var modifiedSlides: [Slide]?
    var deletedSlideIds: [UUID]?
    var selectedElementId: UUID?
    var elementModifications: ElementModification?
    var themeChange: PresentationTheme?
}

// MARK: - Element Modification
struct ElementModification: Codable {
    var elementId: UUID
    var newText: String?
    var newPosition: CGPoint?
    var newSize: CGSize?
    var newColor: Color?
    var newFontSize: CGFloat?
    var newRotation: Double?
    var newZIndex: Int?
}

// MARK: - AI Service Protocol
protocol AIServiceProtocol {
    func processMessage(_ message: String, currentPresentation: Presentation) async throws -> AIMessage
    func generatePresentation(from prompt: String) async throws -> Presentation
    func modifyElement(elementId: UUID, instruction: String, currentPresentation: Presentation) async throws -> AIMessage
}

// MARK: - Mock AI Service
class MockAIService: AIServiceProtocol {
    func processMessage(_ message: String, currentPresentation: Presentation) async throws -> AIMessage {
        // Симуляция обработки сообщения AI
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда задержки
        
        let response = generateAIResponse(for: message, presentation: currentPresentation)
        let changes = generatePresentationChanges(for: message, presentation: currentPresentation)
        
        return AIMessage(content: response, isUser: false, presentationChanges: changes)
    }
    
    func generatePresentation(from prompt: String) async throws -> Presentation {
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 секунды задержки
        
        let presentation = Presentation(title: "AI Generated Presentation")
        
        // Генерируем слайды на основе промпта
        var slides: [Slide] = []
        
        if prompt.lowercased().contains("бизнес") {
            slides = createBusinessPresentation()
        } else if prompt.lowercased().contains("образование") || prompt.lowercased().contains("учеба") {
            slides = createEducationalPresentation()
        } else if prompt.lowercased().contains("творческий") || prompt.lowercased().contains("дизайн") {
            slides = createCreativePresentation()
        } else {
            slides = createDefaultPresentation()
        }
        
        var newPresentation = presentation
        newPresentation.slides = slides
        return newPresentation
    }
    
    func modifyElement(elementId: UUID, instruction: String, currentPresentation: Presentation) async throws -> AIMessage {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let response = "Элемент изменен согласно вашим требованиям: \(instruction)"
        let modification = ElementModification(elementId: elementId)
        
        let changes = PresentationChanges(
            selectedElementId: elementId,
            elementModifications: modification
        )
        
        return AIMessage(content: response, isUser: false, presentationChanges: changes)
    }
    
    private func generateAIResponse(for message: String, presentation: Presentation) -> String {
        let lowercased = message.lowercased()
        
        if lowercased.contains("создай") || lowercased.contains("сделай") {
            return "Отлично! Я создам для вас презентацию. Скажите, какую тему вы хотели бы осветить?"
        } else if lowercased.contains("добавь") || lowercased.contains("вставь") {
            return "Конечно! Я добавлю новый слайд. Что именно вы хотели бы на нем разместить?"
        } else if lowercased.contains("измени") || lowercased.contains("поменяй") {
            return "Хорошо, я изменю элемент. Уточните, пожалуйста, что именно нужно изменить?"
        } else if lowercased.contains("удали") || lowercased.contains("убери") {
            return "Понял, удаляю элемент. Что еще нужно изменить?"
        } else {
            return "Я понимаю вашу просьбу. Давайте создадим отличную презентацию! Что именно вы хотели бы добавить или изменить?"
        }
    }
    
    private func generatePresentationChanges(for message: String, presentation: Presentation) -> PresentationChanges? {
        let lowercased = message.lowercased()
        
        if lowercased.contains("добавь слайд") {
            let newSlide = Slide()
            return PresentationChanges(newSlides: [newSlide])
        } else if lowercased.contains("измени тему") {
            let newTheme: PresentationTheme = presentation.theme == .modern ? .classic : .modern
            return PresentationChanges(themeChange: newTheme)
        }
        
        return nil
    }
    
    private func createBusinessPresentation() -> [Slide] {
        var slides: [Slide] = []
        
        // Титульный слайд
        var titleSlide = Slide()
        titleSlide.elements = [
            TextElement(text: "Бизнес Презентация", fontSize: 36, position: CGPoint(x: 200, y: 200)),
            TextElement(text: "Подзаголовок", fontSize: 24, position: CGPoint(x: 200, y: 280))
        ]
        slides.append(titleSlide)
        
        // Слайд с данными
        var dataSlide = Slide()
        dataSlide.elements = [
            TextElement(text: "Ключевые Показатели", fontSize: 32, position: CGPoint(x: 200, y: 100)),
            TextElement(text: "• Рост продаж: +25%", fontSize: 20, position: CGPoint(x: 100, y: 200)),
            TextElement(text: "• Новые клиенты: 150", fontSize: 20, position: CGPoint(x: 100, y: 250)),
            TextElement(text: "• Доходность: 85%", fontSize: 20, position: CGPoint(x: 100, y: 300))
        ]
        slides.append(dataSlide)
        
        return slides
    }
    
    private func createEducationalPresentation() -> [Slide] {
        var slides: [Slide] = []
        
        var titleSlide = Slide()
        titleSlide.elements = [
            TextElement(text: "Образовательная Презентация", fontSize: 36, position: CGPoint(x: 200, y: 200)),
            TextElement(text: "Тема урока", fontSize: 24, position: CGPoint(x: 200, y: 280))
        ]
        slides.append(titleSlide)
        
        var contentSlide = Slide()
        contentSlide.elements = [
            TextElement(text: "Основные Понятия", fontSize: 32, position: CGPoint(x: 200, y: 100)),
            TextElement(text: "1. Определение", fontSize: 20, position: CGPoint(x: 100, y: 200)),
            TextElement(text: "2. Примеры", fontSize: 20, position: CGPoint(x: 100, y: 250)),
            TextElement(text: "3. Применение", fontSize: 20, position: CGPoint(x: 100, y: 300))
        ]
        slides.append(contentSlide)
        
        return slides
    }
    
    private func createCreativePresentation() -> [Slide] {
        var slides: [Slide] = []
        
        var titleSlide = Slide()
        titleSlide.elements = [
            TextElement(text: "Творческая Презентация", fontSize: 36, position: CGPoint(x: 200, y: 200)),
            TextElement(text: "Вдохновение и идеи", fontSize: 24, position: CGPoint(x: 200, y: 280))
        ]
        slides.append(titleSlide)
        
        return slides
    }
    
    private func createDefaultPresentation() -> [Slide] {
        var slides: [Slide] = []
        
        var titleSlide = Slide()
        titleSlide.elements = [
            TextElement(text: "Новая Презентация", fontSize: 36, position: CGPoint(x: 200, y: 200)),
            TextElement(text: "Создано с помощью AI", fontSize: 24, position: CGPoint(x: 200, y: 280))
        ]
        slides.append(titleSlide)
        
        return slides
    }
}