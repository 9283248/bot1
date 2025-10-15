import SwiftUI

struct PresentationModeView: View {
    @ObservedObject var viewModel: PresentationViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let presentation = viewModel.currentPresentation,
               viewModel.currentSlideIndex < presentation.slides.count {
                
                SlidePresentationView(
                    slide: presentation.slides[viewModel.currentSlideIndex],
                    theme: presentation.theme
                )
                
                // Панель навигации
                VStack {
                    Spacer()
                    
                    HStack {
                        Button("Назад") {
                            viewModel.previousSlide()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .disabled(viewModel.currentSlideIndex == 0)
                        
                        Spacer()
                        
                        Text("\(viewModel.currentSlideIndex + 1) / \(presentation.slides.count)")
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Button("Вперед") {
                            viewModel.nextSlide()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .disabled(viewModel.currentSlideIndex >= presentation.slides.count - 1)
                    }
                    .padding()
                }
            }
            
            // Кнопка закрытия
            VStack {
                HStack {
                    Spacer()
                    
                    Button("Закрыть") {
                        viewModel.endPresentation()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(Capsule())
                }
                .padding()
                
                Spacer()
            }
        }
        .onTapGesture {
            // Переключение на следующий слайд по тапу
            if viewModel.currentSlideIndex < (viewModel.currentPresentation?.slides.count ?? 0) - 1 {
                viewModel.nextSlide()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.x > 50 {
                        // Свайп вправо - предыдущий слайд
                        viewModel.previousSlide()
                    } else if value.translation.x < -50 {
                        // Свайп влево - следующий слайд
                        viewModel.nextSlide()
                    }
                }
        )
    }
}

struct SlidePresentationView: View {
    let slide: Slide
    let theme: PresentationTheme
    
    var body: some View {
        ZStack {
            // Фон слайда
            Rectangle()
                .fill(theme.backgroundColor)
                .ignoresSafeArea()
            
            // Элементы слайда
            ForEach(slide.elements, id: \.id) { element in
                PresentationElementView(element: element)
            }
        }
    }
}

struct PresentationElementView: View {
    let element: SlideElement
    
    var body: some View {
        Group {
            if let textElement = element as? TextElement {
                Text(textElement.text)
                    .font(.system(size: textElement.fontSize, weight: textElement.isBold ? .bold : .regular))
                    .foregroundColor(textElement.textColor)
                    .multilineTextAlignment(textElement.alignment)
                    .italic(textElement.isItalic)
                    .frame(width: textElement.size.width, height: textElement.size.height)
            } else if let imageElement = element as? ImageElement {
                Image(systemName: "photo")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                    .frame(width: imageElement.size.width, height: imageElement.size.height)
            } else if let shapeElement = element as? ShapeElement {
                PresentationShapeView(element: shapeElement)
            }
        }
        .position(element.position)
        .rotationEffect(.degrees(element.rotation))
        .zIndex(Double(element.zIndex))
    }
}

struct PresentationShapeView: View {
    let element: ShapeElement
    
    var body: some View {
        Group {
            switch element.shapeType {
            case .rectangle:
                Rectangle()
                    .fill(element.fillColor)
                    .overlay(
                        Rectangle()
                            .stroke(element.strokeColor, lineWidth: element.strokeWidth)
                    )
            case .circle:
                Circle()
                    .fill(element.fillColor)
                    .overlay(
                        Circle()
                            .stroke(element.strokeColor, lineWidth: element.strokeWidth)
                    )
            case .triangle:
                Triangle()
                    .fill(element.fillColor)
                    .overlay(
                        Triangle()
                            .stroke(element.strokeColor, lineWidth: element.strokeWidth)
                    )
            case .star:
                Star()
                    .fill(element.fillColor)
                    .overlay(
                        Star()
                            .stroke(element.strokeColor, lineWidth: element.strokeWidth)
                    )
            case .arrow:
                Arrow()
                    .fill(element.fillColor)
                    .overlay(
                        Arrow()
                            .stroke(element.strokeColor, lineWidth: element.strokeWidth)
                    )
            }
        }
        .frame(width: element.size.width, height: element.size.height)
    }
}

#Preview {
    let viewModel = PresentationViewModel()
    viewModel.startPresentation()
    return PresentationModeView(viewModel: viewModel)
}