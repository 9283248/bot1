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
        VStack {
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
                    .padding()
                }
            }
        }
        .searchable(text: $searchText, prompt: "Поиск презентаций")
        .sheet(item: $selectedPresentation) { presentation in
            SlideEditorView(presentation: presentation)
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
        VStack(alignment: .leading, spacing: 12) {
            // Миниатюра презентации
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "doc.text")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("\(presentation.slides.count) слайдов")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(presentation.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("Изменено: \(presentation.modifiedAt, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
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
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Нет презентаций")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Создайте свою первую презентацию, нажав кнопку +")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    PresentationGalleryView(presentationManager: PresentationManager())
}