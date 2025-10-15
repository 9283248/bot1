import Foundation
import SwiftUI

class Presentation: ObservableObject, Identifiable {
    let id = UUID()
    @Published var title: String
    @Published var slides: [Slide]
    @Published var createdAt: Date
    @Published var modifiedAt: Date
    @Published var thumbnail: UIImage?
    
    init(title: String) {
        self.title = title
        self.slides = [Slide(title: "Новый слайд")]
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
    
    func addSlide() {
        let newSlide = Slide(title: "Слайд \(slides.count + 1)")
        slides.append(newSlide)
        modifiedAt = Date()
    }
    
    func removeSlide(at index: Int) {
        guard index < slides.count else { return }
        slides.remove(at: index)
        modifiedAt = Date()
    }
    
    func moveSlide(from source: IndexSet, to destination: Int) {
        slides.move(fromOffsets: source, toOffset: destination)
        modifiedAt = Date()
    }
    
    func generateThumbnail() {
        // Генерируем миниатюру из первого слайда
        if let firstSlide = slides.first {
            // Здесь будет логика генерации миниатюры
            // Пока оставляем пустым
        }
    }
}

// MARK: - Sample Data
extension Presentation {
    static let samplePresentations: [Presentation] = [
        {
            let presentation = Presentation(title: "Моя первая презентация")
            presentation.slides = [
                Slide(title: "Заголовок", elements: [
                    TextElement(text: "Добро пожаловать!", position: CGPoint(x: 100, y: 100), size: CGSize(width: 200, height: 50))
                ]),
                Slide(title: "Содержание", elements: [
                    TextElement(text: "Основные темы:", position: CGPoint(x: 50, y: 80), size: CGSize(width: 300, height: 40)),
                    TextElement(text: "• Тема 1", position: CGPoint(x: 80, y: 140), size: CGSize(width: 250, height: 30)),
                    TextElement(text: "• Тема 2", position: CGPoint(x: 80, y: 180), size: CGSize(width: 250, height: 30))
                ])
            ]
            return presentation
        }(),
        {
            let presentation = Presentation(title: "Бизнес-план")
            presentation.slides = [
                Slide(title: "Обзор", elements: [
                    TextElement(text: "Бизнес-план 2024", position: CGPoint(x: 100, y: 100), size: CGSize(width: 200, height: 50))
                ])
            ]
            return presentation
        }()
    ]
}