import Foundation
import SwiftUI

class PresentationManager: ObservableObject {
    @Published var presentations: [Presentation] = []
    @Published var currentPresentation: Presentation?
    
    init() {
        loadPresentations()
    }
    
    func createPresentation(title: String) {
        let presentation = Presentation(title: title)
        presentations.append(presentation)
        savePresentations()
    }
    
    func deletePresentation(_ presentation: Presentation) {
        presentations.removeAll { $0.id == presentation.id }
        savePresentations()
    }
    
    func duplicatePresentation(_ presentation: Presentation) {
        let duplicatedPresentation = Presentation(title: "\(presentation.title) (копия)")
        duplicatedPresentation.slides = presentation.slides.map { slide in
            let newSlide = Slide(title: slide.title, backgroundColor: slide.backgroundColor)
            newSlide.elements = slide.elements
            return newSlide
        }
        presentations.append(duplicatedPresentation)
        savePresentations()
    }
    
    func openPresentation(_ presentation: Presentation) {
        currentPresentation = presentation
    }
    
    private func savePresentations() {
        // Здесь будет логика сохранения в UserDefaults или Core Data
        // Пока оставляем пустым
    }
    
    private func loadPresentations() {
        // Загружаем примеры презентаций
        presentations = Presentation.samplePresentations
    }
}