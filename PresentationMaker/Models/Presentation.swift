import Foundation
import SwiftUI

// MARK: - Presentation Model
struct Presentation: Identifiable, Codable {
    let id = UUID()
    var title: String
    var slides: [Slide]
    var createdAt: Date
    var modifiedAt: Date
    var theme: PresentationTheme
    
    init(title: String, theme: PresentationTheme = .modern) {
        self.title = title
        self.slides = [Slide()]
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.theme = theme
    }
}

// MARK: - Slide Model
struct Slide: Identifiable, Codable {
    let id = UUID()
    var elements: [SlideElement]
    var backgroundColor: Color
    var backgroundImage: String?
    
    init() {
        self.elements = []
        self.backgroundColor = .white
        self.backgroundImage = nil
    }
}

// MARK: - Slide Element Protocol
protocol SlideElement: Identifiable, Codable {
    var id: UUID { get }
    var position: CGPoint { get set }
    var size: CGSize { get set }
    var rotation: Double { get set }
    var zIndex: Int { get set }
}

// MARK: - Text Element
struct TextElement: SlideElement {
    let id = UUID()
    var position: CGPoint
    var size: CGSize
    var rotation: Double = 0
    var zIndex: Int = 0
    
    var text: String
    var fontSize: CGFloat
    var fontName: String
    var textColor: Color
    var alignment: TextAlignment
    var isBold: Bool
    var isItalic: Bool
    
    init(text: String = "Новый текст", position: CGPoint = .zero, size: CGSize = CGSize(width: 200, height: 50)) {
        self.text = text
        self.position = position
        self.size = size
        self.fontSize = 24
        self.fontName = "Helvetica"
        self.textColor = .black
        self.alignment = .center
        self.isBold = false
        self.isItalic = false
    }
}

// MARK: - Image Element
struct ImageElement: SlideElement {
    let id = UUID()
    var position: CGPoint
    var size: CGSize
    var rotation: Double = 0
    var zIndex: Int = 0
    
    var imageName: String
    var aspectRatio: ContentMode
    
    init(imageName: String, position: CGPoint = .zero, size: CGSize = CGSize(width: 200, height: 150)) {
        self.imageName = imageName
        self.position = position
        self.size = size
        self.aspectRatio = .fit
    }
}

// MARK: - Shape Element
struct ShapeElement: SlideElement {
    let id = UUID()
    var position: CGPoint
    var size: CGSize
    var rotation: Double = 0
    var zIndex: Int = 0
    
    var shapeType: ShapeType
    var fillColor: Color
    var strokeColor: Color
    var strokeWidth: CGFloat
    
    init(shapeType: ShapeType, position: CGPoint = .zero, size: CGSize = CGSize(width: 100, height: 100)) {
        self.shapeType = shapeType
        self.position = position
        self.size = size
        self.fillColor = .blue
        self.strokeColor = .black
        self.strokeWidth = 2
    }
}

// MARK: - Shape Type Enum
enum ShapeType: String, CaseIterable, Codable {
    case rectangle = "rectangle"
    case circle = "circle"
    case triangle = "triangle"
    case star = "star"
    case arrow = "arrow"
}

// MARK: - Presentation Theme
enum PresentationTheme: String, CaseIterable, Codable {
    case modern = "modern"
    case classic = "classic"
    case colorful = "colorful"
    case minimal = "minimal"
    
    var primaryColor: Color {
        switch self {
        case .modern:
            return .blue
        case .classic:
            return .gray
        case .colorful:
            return .purple
        case .minimal:
            return .black
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .modern:
            return .cyan
        case .classic:
            return .white
        case .colorful:
            return .orange
        case .minimal:
            return .gray
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .modern:
            return Color(red: 0.95, green: 0.97, blue: 1.0)
        case .classic:
            return .white
        case .colorful:
            return Color(red: 0.98, green: 0.95, blue: 1.0)
        case .minimal:
            return .white
        }
    }
}