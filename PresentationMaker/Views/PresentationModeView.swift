import SwiftUI

struct PresentationModeView: View {
    @ObservedObject var viewModel: PresentationViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Фоновый градиент
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.1, blue: 0.3),
                    Color(red: 0.1, green: 0.2, blue: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if let presentation = viewModel.currentPresentation,
               viewModel.currentSlideIndex < presentation.slides.count {
                
                SlidePresentationView(
                    slide: presentation.slides[viewModel.currentSlideIndex],
                    theme: presentation.theme
                )
                
                // Панель навигации с стеклянным эффектом
                VStack {
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            viewModel.previousSlide()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(viewModel.currentSlideIndex == 0)
                        .opacity(viewModel.currentSlideIndex == 0 ? 0.5 : 1.0)
                        
                        Spacer()
                        
                        Text("\(viewModel.currentSlideIndex + 1) / \(presentation.slides.count)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.nextSlide()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(viewModel.currentSlideIndex >= presentation.slides.count - 1)
                        .opacity(viewModel.currentSlideIndex >= presentation.slides.count - 1 ? 0.5 : 1.0)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
            
            // Кнопка закрытия с стеклянным эффектом
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        viewModel.endPresentation()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Закрыть")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
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
            // Фон слайда с стеклянным эффектом
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
            
            // Элементы слайда
            ForEach(slide.elements, id: \.id) { element in
                PresentationElementView(element: element)
            }
        }
        .padding(20)
    }
}

struct PresentationElementView: View {
    let element: SlideElement
    
    var body: some View {
        Group {
            if let textElement = element as? TextElement {
                Text(textElement.text)
                    .font(.system(size: textElement.fontSize, weight: textElement.fontWeight))
                    .foregroundColor(textElement.textColor)
                    .multilineTextAlignment(textElement.textAlignment)
                    .frame(width: textElement.size.width, height: textElement.size.height)
            } else if let imageElement = element as? ImageElement {
                Image(systemName: "photo")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.7))
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