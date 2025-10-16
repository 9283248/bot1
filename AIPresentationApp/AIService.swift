import Foundation

class AIService: ObservableObject {
    private let apiKey = "YOUR_OPENAI_API_KEY" // Замените на ваш API ключ
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    func generatePresentation(prompt: String) async throws -> PresentationData {
        let requestBody = createRequest(prompt: prompt)
        
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIServiceError.invalidResponse
        }
        
        let aiResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        return try parsePresentationFromResponse(aiResponse.choices.first?.message.content ?? "")
    }
    
    private func createRequest(prompt: String) -> [String: Any] {
        return [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": """
                    Ты - эксперт по созданию презентаций. Создай структуру презентации на основе запроса пользователя.
                    Ответь в формате JSON со следующей структурой:
                    {
                        "title": "Название презентации",
                        "theme": "Цветовая тема",
                        "duration": 10,
                        "slides": [
                            {
                                "title": "Заголовок слайда",
                                "content": "Содержимое слайда",
                                "slideType": "title",
                                "order": 1
                            }
                        ]
                    }
                    
                    Типы слайдов: title, content, image, chart, conclusion
                    """
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 2000,
            "temperature": 0.7
        ]
    }
    
    private func parsePresentationFromResponse(_ response: String) throws -> PresentationData {
        // Очищаем ответ от markdown форматирования
        let cleanResponse = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanResponse.data(using: .utf8) else {
            throw AIServiceError.invalidData
        }
        
        let presentation = try JSONDecoder().decode(PresentationData.self, from: data)
        return presentation
    }
}

enum AIServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case apiKeyMissing
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .invalidResponse:
            return "Неверный ответ от сервера"
        case .invalidData:
            return "Неверные данные"
        case .apiKeyMissing:
            return "Отсутствует API ключ"
        }
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}