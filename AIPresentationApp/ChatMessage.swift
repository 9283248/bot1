import Foundation

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let presentationData: PresentationData?
    
    init(content: String, isUser: Bool, presentationData: PresentationData? = nil) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
        self.presentationData = presentationData
    }
}

struct PresentationData: Codable {
    let title: String
    let slides: [Slide]
    let theme: String
    let duration: Int // в минутах
}

struct Slide: Codable, Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let slideType: SlideType
    let order: Int
}

enum SlideType: String, CaseIterable, Codable {
    case title = "title"
    case content = "content"
    case image = "image"
    case chart = "chart"
    case conclusion = "conclusion"
}