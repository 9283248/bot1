import SwiftUI

struct PresentationView: View {
    @ObservedObject var viewModel: PresentationViewModel
    @State private var selectedSlideId: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            // Панель инструментов
            HStack {
                Button("Назад к чату") {
                    // Возврат к чату
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text(viewModel.currentPresentation?.title ?? "Презентация")
                    .font(.headline)
                
                Spacer()
                
                Button("Презентация") {
                    viewModel.startPresentation()
                }
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(radius: 1)
            
            HStack(spacing: 0) {
                // Панель слайдов
                VStack(alignment: .leading) {
                    Text("Слайды")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(Array((viewModel.currentPresentation?.slides ?? []).enumerated()), id: \.element.id) { index, slide in
                                SlideThumbnail(
                                    slide: slide,
                                    index: index,
                                    isSelected: selectedSlideId == slide.id
                                ) {
                                    selectedSlideId = slide.id
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(width: 200)
                .background(Color(.systemGray6))
                
                Divider()
                
                // Основная область редактирования
                if let presentation = viewModel.currentPresentation,
                   let selectedSlide = presentation.slides.first(where: { $0.id == selectedSlideId }) ?? presentation.slides.first {
                    
                    SlideEditorView(
                        slide: selectedSlide,
                        theme: presentation.theme,
                        selectedElementId: viewModel.selectedElementId,
                        onElementSelected: { elementId in
                            viewModel.selectElement(elementId)
                        },
                        onElementDeselected: {
                            viewModel.deselectElement()
                        }
                    )
                } else {
                    VStack {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Выберите слайд для редактирования")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .onAppear {
            if let firstSlide = viewModel.currentPresentation?.slides.first {
                selectedSlideId = firstSlide.id
            }
        }
    }
}

struct SlideThumbnail: View {
    let slide: Slide
    let index: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.gray, lineWidth: isSelected ? 2 : 1)
                    )
                
                // Предварительный просмотр элементов слайда
                ForEach(slide.elements.prefix(3), id: \.id) { element in
                    if let textElement = element as? TextElement {
                        Text(textElement.text)
                            .font(.system(size: 8))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .position(
                                x: textElement.position.x * 0.1,
                                y: textElement.position.y * 0.1
                            )
                    }
                }
            }
            
            Text("Слайд \(index + 1)")
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .primary)
        }
        .onTapGesture {
            onTap()
        }
    }
}

struct SlideEditorView: View {
    let slide: Slide
    let theme: PresentationTheme
    let selectedElementId: UUID?
    let onElementSelected: (UUID) -> Void
    let onElementDeselected: () -> Void
    
    var body: some View {
        ZStack {
            // Фон слайда
            Rectangle()
                .fill(theme.backgroundColor)
                .aspectRatio(16/9, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            // Элементы слайда
            ForEach(slide.elements, id: \.id) { element in
                ElementView(
                    element: element,
                    isSelected: selectedElementId == element.id,
                    onTap: {
                        if selectedElementId == element.id {
                            onElementDeselected()
                        } else {
                            onElementSelected(element.id)
                        }
                    }
                )
            }
        }
        .padding()
        .onTapGesture {
            onElementDeselected()
        }
    }
}

struct ElementView: View {
    let element: SlideElement
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Group {
            if let textElement = element as? TextElement {
                TextElementView(element: textElement, isSelected: isSelected, onTap: onTap)
            } else if let imageElement = element as? ImageElement {
                ImageElementView(element: imageElement, isSelected: isSelected, onTap: onTap)
            } else if let shapeElement = element as? ShapeElement {
                ShapeElementView(element: shapeElement, isSelected: isSelected, onTap: onTap)
            }
        }
        .position(element.position)
        .frame(width: element.size.width, height: element.size.height)
        .rotationEffect(.degrees(element.rotation))
        .zIndex(Double(element.zIndex))
    }
}

struct TextElementView: View {
    let element: TextElement
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Text(element.text)
            .font(.system(size: element.fontSize, weight: element.isBold ? .bold : .regular))
            .foregroundColor(element.textColor)
            .multilineTextAlignment(element.alignment)
            .italic(element.isItalic)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    .background(Color.clear)
            )
            .onTapGesture {
                onTap()
            }
    }
}

struct ImageElementView: View {
    let element: ImageElement
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Image(systemName: "photo")
            .font(.system(size: 40))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
                    .background(Color.gray.opacity(0.1))
            )
            .onTapGesture {
                onTap()
            }
    }
}

struct ShapeElementView: View {
    let element: ShapeElement
    let isSelected: Bool
    let onTap: () -> Void
    
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Custom Shapes
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        
        var path = Path()
        
        for i in 0..<10 {
            let angle = Double(i) * .pi / 5 - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let arrowHeadWidth = rect.width * 0.3
        
        // Стрелка
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - arrowHeadWidth, y: rect.midY))
        
        // Наконечник стрелки
        path.addLine(to: CGPoint(x: rect.maxX - arrowHeadWidth, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - arrowHeadWidth, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - arrowHeadWidth, y: rect.midY))
        
        return path
    }
}

#Preview {
    PresentationView(viewModel: PresentationViewModel())
}