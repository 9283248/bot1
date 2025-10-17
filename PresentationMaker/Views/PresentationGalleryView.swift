import SwiftUI

struct PresentationGalleryView: View {
    @ObservedObject var presentationManager: PresentationManager
    @State private var searchText = ""
    @State private var selectedPresentation: Presentation?
    
    private var filteredPresentations: [Presentation] {
        if searchText.isEmpty {
            return presentationManager.presentations
        } else {
            return presentationManager.presentations.filter { presentation in
                presentation.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
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
            
            VStack(spacing: 0) {
                // Поисковая строка
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.system(size: 16, weight: .medium))
                            
                            TextField("Поиск презентаций", text: $searchText)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                if presentationManager.presentations.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 300), spacing: 20)
                        ], spacing: 20) {
                            ForEach(filteredPresentations) { presentation in
                                PresentationCardView(
                                    presentation: presentation,
                                    onTap: {
                                        selectedPresentation = presentation
                                    },
                                    onDelete: {
                                        presentationManager.deletePresentation(presentation)
                                    },
                                    onDuplicate: {
                                        presentationManager.duplicatePresentation(presentation)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .sheet(item: $selectedPresentation) { presentation in
            PresentationView(viewModel: PresentationViewModel())
        }
    }
}

struct PresentationCardView: View {
    let presentation: Presentation
    let onTap: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    
    @State private var showingActionSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Миниатюра презентации
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .frame(height: 200)
                
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "doc.text")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("\(presentation.slides.count) слайдов")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(presentation.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text("Изменено: \(presentation.modifiedAt, style: .date)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .onTapGesture {
            onTap()
        }
        .contextMenu {
            Button("Открыть", action: onTap)
            Button("Дублировать", action: onDuplicate)
            Button("Удалить", role: .destructive, action: onDelete)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 12) {
                Text("Нет презентаций")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Создайте свою первую презентацию через чат с AI")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 40)
    }
}

#Preview {
    PresentationGalleryView(presentationManager: PresentationManager())
}