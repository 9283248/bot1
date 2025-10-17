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

// MARK: - OpenAI Service
class OpenAIService: AIServiceProtocol {
    private let apiKey = "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"
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    func processMessage(_ message: String, currentPresentation: Presentation) async throws -> AIMessage {
        let systemPrompt = createSystemPrompt(for: currentPresentation)
        let request = createChatRequest(systemPrompt: systemPrompt, userMessage: message)
        
        let response = try await sendRequest(request)
        let aiResponse = try parseAIResponse(response)
        
        return AIMessage(
            content: aiResponse.content,
            isUser: false,
            presentationChanges: aiResponse.changes
        )
    }
    
    func generatePresentation(from prompt: String) async throws -> Presentation {
        let systemPrompt = """
        Ты - эксперт по созданию презентаций. Создай презентацию на основе запроса пользователя.
        Формат ответа должен быть JSON с полями:
        {
            "title": "Название презентации",
            "slides": [
                {
                    "title": "Заголовок слайда",
                    "elements": [
                        {
                            "type": "text",
                            "text": "Текст элемента",
                            "position": {"x": 200, "y": 200},
                            "size": {"width": 300, "height": 50},
                            "fontSize": 24,
                            "color": "black"
                        }
                    ]
                }
            ]
        }
        
        Создай презентацию в формате 16:9. Используй современный дизайн.
        """
        
        let request = createChatRequest(systemPrompt: systemPrompt, userMessage: prompt)
        let response = try await sendRequest(request)
        
        return try parsePresentationResponse(response)
    }
    
    func modifyElement(elementId: UUID, instruction: String, currentPresentation: Presentation) async throws -> AIMessage {
        let systemPrompt = createSystemPrompt(for: currentPresentation)
        let userMessage = "Измени элемент с ID \(elementId): \(instruction)"
        
        let request = createChatRequest(systemPrompt: systemPrompt, userMessage: userMessage)
        let response = try await sendRequest(request)
        let aiResponse = try parseAIResponse(response)
        
        return AIMessage(
            content: aiResponse.content,
            isUser: false,
            presentationChanges: aiResponse.changes
        )
    }
    
    private func createSystemPrompt(for presentation: Presentation) -> String {
        return """
        Ты - AI-ассистент для создания и редактирования презентаций. 
        Текущая презентация: "\(presentation.title)" с \(presentation.slides.count) слайдами.
        
        Формат ответа должен быть JSON с полями:
        {
            "content": "Твой ответ пользователю",
            "changes": {
                "newSlides": [...],
                "modifiedSlides": [...],
                "deletedSlideIds": [...],
                "selectedElementId": "uuid",
                "elementModifications": {...},
                "themeChange": "modern|classic|creative"
            }
        }
        
        Презентации должны быть в формате 16:9. Используй современный стеклянный дизайн.
        Отвечай на русском языке.
        """
    }
    
    private func createChatRequest(systemPrompt: String, userMessage: String) -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.7,
            "max_tokens": 2000
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        return request
    }
    
    private func sendRequest(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.networkError
        }
        
        return data
    }
    
    private func parseAIResponse(_ data: Data) throws -> (content: String, changes: PresentationChanges?) {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.parsingError
        }
        
        // Пытаемся извлечь JSON из ответа
        if let jsonStart = content.range(of: "{"),
           let jsonEnd = content.range(of: "}", options: .backwards, range: jsonStart.upperBound..<content.endIndex) {
            let jsonString = String(content[jsonStart.lowerBound...jsonEnd.upperBound])
            
            if let jsonData = jsonString.data(using: .utf8),
               let parsedResponse = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                
                let responseContent = parsedResponse["content"] as? String ?? content
                let changes = parsePresentationChanges(from: parsedResponse["changes"] as? [String: Any])
                
                return (responseContent, changes)
            }
        }
        
        return (content, nil)
    }
    
    private func parsePresentationResponse(_ data: Data) throws -> Presentation {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.parsingError
        }
        
        // Извлекаем JSON из ответа
        guard let jsonStart = content.range(of: "{"),
              let jsonEnd = content.range(of: "}", options: .backwards, range: jsonStart.upperBound..<content.endIndex) else {
            throw AIError.parsingError
        }
        
        let jsonString = String(content[jsonStart.lowerBound...jsonEnd.upperBound])
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AIError.parsingError
        }
        
        let decoder = JSONDecoder()
        let presentationData = try decoder.decode(PresentationData.self, from: jsonData)
        
        return presentationData.toPresentation()
    }
    
    private func parsePresentationChanges(from changesDict: [String: Any]?) -> PresentationChanges? {
        guard let changes = changesDict else { return nil }
        
        var presentationChanges = PresentationChanges()
        
        if let newSlidesData = changes["newSlides"] as? [[String: Any]] {
            presentationChanges.newSlides = newSlidesData.compactMap { slideData in
                parseSlide(from: slideData)
            }
        }
        
        if let modifiedSlidesData = changes["modifiedSlides"] as? [[String: Any]] {
            presentationChanges.modifiedSlides = modifiedSlidesData.compactMap { slideData in
                parseSlide(from: slideData)
            }
        }
        
        if let deletedIds = changes["deletedSlideIds"] as? [String] {
            presentationChanges.deletedSlideIds = deletedIds.compactMap { UUID(uuidString: $0) }
        }
        
        if let selectedId = changes["selectedElementId"] as? String {
            presentationChanges.selectedElementId = UUID(uuidString: selectedId)
        }
        
        if let theme = changes["themeChange"] as? String {
            switch theme {
            case "modern":
                presentationChanges.themeChange = .modern
            case "classic":
                presentationChanges.themeChange = .classic
            case "creative":
                presentationChanges.themeChange = .creative
            default:
                break
            }
        }
        
        return presentationChanges
    }
    
    private func parseSlide(from slideData: [String: Any]) -> Slide? {
        guard let title = slideData["title"] as? String else { return nil }
        
        var slide = Slide(title: title)
        
        if let elementsData = slideData["elements"] as? [[String: Any]] {
            slide.elements = elementsData.compactMap { elementData in
                parseElement(from: elementData)
            }
        }
        
        return slide
    }
    
    private func parseElement(from elementData: [String: Any]) -> SlideElement? {
        guard let type = elementData["type"] as? String else { return nil }
        
        let position = parsePoint(from: elementData["position"] as? [String: Any])
        let size = parseSize(from: elementData["size"] as? [String: Any])
        let fontSize = elementData["fontSize"] as? CGFloat ?? 16
        let color = parseColor(from: elementData["color"] as? String)
        
        switch type {
        case "text":
            guard let text = elementData["text"] as? String else { return nil }
            return TextElement(
                text: text,
                fontSize: fontSize,
                position: position,
                size: size,
                color: color
            )
        default:
            return nil
        }
    }
    
    private func parsePoint(from pointData: [String: Any]?) -> CGPoint {
        guard let point = pointData,
              let x = point["x"] as? CGFloat,
              let y = point["y"] as? CGFloat else {
            return CGPoint(x: 0, y: 0)
        }
        return CGPoint(x: x, y: y)
    }
    
    private func parseSize(from sizeData: [String: Any]?) -> CGSize {
        guard let size = sizeData,
              let width = size["width"] as? CGFloat,
              let height = size["height"] as? CGFloat else {
            return CGSize(width: 200, height: 50)
        }
        return CGSize(width: width, height: height)
    }
    
    private func parseColor(from colorString: String?) -> Color {
        guard let color = colorString else { return .black }
        
        switch color.lowercased() {
        case "red":
            return .red
        case "blue":
            return .blue
        case "green":
            return .green
        case "purple":
            return .purple
        case "orange":
            return .orange
        case "pink":
            return .pink
        case "gray", "grey":
            return .gray
        default:
            return .black
        }
    }
}

// MARK: - Supporting Types
struct PresentationData: Codable {
    let title: String
    let slides: [SlideData]
    
    func toPresentation() -> Presentation {
        let presentation = Presentation(title: title)
        presentation.slides = slides.map { $0.toSlide() }
        return presentation
    }
}

struct SlideData: Codable {
    let title: String
    let elements: [ElementData]
    
    func toSlide() -> Slide {
        var slide = Slide(title: title)
        slide.elements = elements.compactMap { $0.toElement() }
        return slide
    }
}

struct ElementData: Codable {
    let type: String
    let text: String?
    let position: PointData?
    let size: SizeData?
    let fontSize: CGFloat?
    let color: String?
    
    func toElement() -> SlideElement? {
        guard type == "text", let text = text else { return nil }
        
        let position = self.position?.toCGPoint() ?? CGPoint(x: 200, y: 200)
        let size = self.size?.toCGSize() ?? CGSize(width: 300, height: 50)
        let fontSize = self.fontSize ?? 16
        let color = parseColor(from: self.color)
        
        return TextElement(
            text: text,
            fontSize: fontSize,
            position: position,
            size: size,
            color: color
        )
    }
    
    private func parseColor(from colorString: String?) -> Color {
        guard let color = colorString else { return .black }
        
        switch color.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "gray", "grey": return .gray
        default: return .black
        }
    }
}

struct PointData: Codable {
    let x: CGFloat
    let y: CGFloat
    
    func toCGPoint() -> CGPoint {
        return CGPoint(x: x, y: y)
    }
}

struct SizeData: Codable {
    let width: CGFloat
    let height: CGFloat
    
    func toCGSize() -> CGSize {
        return CGSize(width: width, height: height)
    }
}

// MARK: - Errors
enum AIError: Error {
    case networkError
    case parsingError
    case invalidResponse
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