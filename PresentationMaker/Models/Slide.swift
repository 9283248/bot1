import Foundation
import SwiftUI

class Slide: ObservableObject, Identifiable {
    let id = UUID()
    @Published var title: String
    @Published var elements: [SlideElement]
    @Published var backgroundColor: Color
    @Published var backgroundImage: UIImage?
    
    // Формат 16:9 для слайдов
    static let aspectRatio: CGFloat = 16.0 / 9.0
    static let defaultWidth: CGFloat = 400
    static let defaultHeight: CGFloat = defaultWidth / aspectRatio
    
    init(title: String, elements: [SlideElement] = [], backgroundColor: Color = .white) {
        self.title = title
        self.elements = elements
        self.backgroundColor = backgroundColor
    }
    
    func addElement(_ element: SlideElement) {
        elements.append(element)
    }
    
    func removeElement(_ element: SlideElement) {
        elements.removeAll { $0.id == element.id }
    }
    
    func moveElement(_ element: SlideElement, to position: CGPoint) {
        if let index = elements.firstIndex(where: { $0.id == element.id }) {
            elements[index].position = position
        }
    }
    
    func resizeElement(_ element: SlideElement, to size: CGSize) {
        if let index = elements.firstIndex(where: { $0.id == element.id }) {
            elements[index].size = size
        }
    }
    
    func bringToFront(_ element: SlideElement) {
        guard let index = elements.firstIndex(where: { $0.id == element.id }) else { return }
        let element = elements.remove(at: index)
        elements.append(element)
    }
    
    func sendToBack(_ element: SlideElement) {
        guard let index = elements.firstIndex(where: { $0.id == element.id }) else { return }
        let element = elements.remove(at: index)
        elements.insert(element, at: 0)
    }
}

// MARK: - Slide Templates
extension Slide {
    static func titleSlide(title: String, subtitle: String? = nil) -> Slide {
        let slide = Slide(title: "Титульный слайд")
        slide.elements = [
            TextElement(
                text: title,
                position: CGPoint(x: 50, y: 200),
                size: CGSize(width: 300, height: 60),
                fontSize: 32,
                fontWeight: .bold,
                textColor: .black,
                textAlignment: .center
            )
        ]
        
        if let subtitle = subtitle {
            slide.elements.append(
                TextElement(
                    text: subtitle,
                    position: CGPoint(x: 50, y: 280),
                    size: CGSize(width: 300, height: 40),
                    fontSize: 18,
                    fontWeight: .regular,
                    textColor: .gray,
                    textAlignment: .center
                )
            )
        }
        
        return slide
    }
    
    static func contentSlide(title: String, bulletPoints: [String]) -> Slide {
        let slide = Slide(title: "Слайд с содержанием")
        var elements: [SlideElement] = []
        
        // Заголовок
        elements.append(
            TextElement(
                text: title,
                position: CGPoint(x: 50, y: 50),
                size: CGSize(width: 300, height: 40),
                fontSize: 24,
                fontWeight: .bold,
                textColor: .black
            )
        )
        
        // Маркированный список
        var yPosition: CGFloat = 120
        for (index, point) in bulletPoints.enumerated() {
            elements.append(
                TextElement(
                    text: "• \(point)",
                    position: CGPoint(x: 70, y: yPosition),
                    size: CGSize(width: 280, height: 30),
                    fontSize: 16,
                    fontWeight: .regular,
                    textColor: .black
                )
            )
            yPosition += 40
        }
        
        slide.elements = elements
        return slide
    }
    
    static func imageSlide(title: String, image: UIImage?) -> Slide {
        let slide = Slide(title: "Слайд с изображением")
        slide.elements = [
            TextElement(
                text: title,
                position: CGPoint(x: 50, y: 50),
                size: CGSize(width: 300, height: 40),
                fontSize: 24,
                fontWeight: .bold,
                textColor: .black
            )
        ]
        
        if let image = image {
            slide.elements.append(
                ImageElement(
                    image: image,
                    position: CGPoint(x: 50, y: 120),
                    size: CGSize(width: 300, height: 200)
                )
            )
        }
        
        return slide
    }
}