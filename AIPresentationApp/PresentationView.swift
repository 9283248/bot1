import SwiftUI

struct PresentationView: View {
    let presentation: PresentationData
    @State private var currentSlideIndex = 0
    @State private var isPresenting = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isPresenting {
                    PresentationModeView(
                        presentation: presentation,
                        currentSlideIndex: $currentSlideIndex,
                        isPresenting: $isPresenting
                    )
                } else {
                    EditModeView(
                        presentation: presentation,
                        currentSlideIndex: $currentSlideIndex
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isPresenting ? "Редактировать" : "Презентация") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresenting.toggle()
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct EditModeView: View {
    let presentation: PresentationData
    @Binding var currentSlideIndex: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок презентации
            VStack(spacing: 8) {
                Text(presentation.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack {
                    Label("\(presentation.slides.count) слайдов", systemImage: "rectangle.stack")
                    Spacer()
                    Label("\(presentation.duration) мин", systemImage: "clock")
                    Spacer()
                    Text(presentation.theme)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color.gray.opacity(0.05))
            
            // Слайды
            TabView(selection: $currentSlideIndex) {
                ForEach(Array(presentation.slides.enumerated()), id: \.offset) { index, slide in
                    SlideEditView(slide: slide, slideNumber: index + 1)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Навигация по слайдам
            HStack {
                Button(action: {
                    if currentSlideIndex > 0 {
                        withAnimation {
                            currentSlideIndex -= 1
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(currentSlideIndex > 0 ? .blue : .gray)
                }
                .disabled(currentSlideIndex == 0)
                
                Spacer()
                
                Text("\(currentSlideIndex + 1) из \(presentation.slides.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    if currentSlideIndex < presentation.slides.count - 1 {
                        withAnimation {
                            currentSlideIndex += 1
                        }
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(currentSlideIndex < presentation.slides.count - 1 ? .blue : .gray)
                }
                .disabled(currentSlideIndex == presentation.slides.count - 1)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
        }
    }
}

struct PresentationModeView: View {
    let presentation: PresentationData
    @Binding var currentSlideIndex: Int
    @Binding var isPresenting: Bool
    @State private var isFullScreen = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                if !isFullScreen {
                    HStack {
                        Text(presentation.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Button("Выйти") {
                            isPresenting = false
                        }
                        .foregroundColor(.white)
                    }
                    .padding()
                }
                
                Spacer()
                
                TabView(selection: $currentSlideIndex) {
                    ForEach(Array(presentation.slides.enumerated()), id: \.offset) { index, slide in
                        SlidePresentationView(slide: slide, slideNumber: index + 1)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onTapGesture {
                    withAnimation {
                        isFullScreen.toggle()
                    }
                }
                
                Spacer()
                
                if !isFullScreen {
                    HStack {
                        Button(action: {
                            if currentSlideIndex > 0 {
                                withAnimation {
                                    currentSlideIndex -= 1
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(currentSlideIndex > 0 ? .white : .gray)
                        }
                        .disabled(currentSlideIndex == 0)
                        
                        Spacer()
                        
                        Text("\(currentSlideIndex + 1) / \(presentation.slides.count)")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            if currentSlideIndex < presentation.slides.count - 1 {
                                withAnimation {
                                    currentSlideIndex += 1
                                }
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(currentSlideIndex < presentation.slides.count - 1 ? .white : .gray)
                        }
                        .disabled(currentSlideIndex == presentation.slides.count - 1)
                    }
                    .padding()
                }
            }
        }
    }
}

struct SlideEditView: View {
    let slide: Slide
    let slideNumber: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Слайд \(slideNumber)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 16) {
                Text(slide.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                Text(slide.content)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct SlidePresentationView: View {
    let slide: Slide
    let slideNumber: Int
    
    var body: some View {
        VStack(spacing: 40) {
            Text(slide.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(slide.content)
                .font(.title2)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    let samplePresentation = PresentationData(
        title: "Пример презентации",
        slides: [
            Slide(title: "Добро пожаловать", content: "Это пример презентации, созданной с помощью AI", slideType: .title, order: 1),
            Slide(title: "Основные темы", content: "• Тема 1\n• Тема 2\n• Тема 3", slideType: .content, order: 2),
            Slide(title: "Заключение", content: "Спасибо за внимание!", slideType: .conclusion, order: 3)
        ],
        theme: "Синяя",
        duration: 10
    )
    
    PresentationView(presentation: samplePresentation)
}