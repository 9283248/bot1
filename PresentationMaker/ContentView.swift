import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PresentationViewModel()
    @State private var showingGallery = false
    
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
                // Верхняя панель навигации
                HStack {
                    Button(action: {
                        showingGallery.toggle()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.grid.2x2")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Галерея")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("AI Презентация")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Создавайте через чат")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.generateNewPresentation(from: "Создай новую презентацию")
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Новая")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 0))
                .overlay(
                    Rectangle()
                        .fill(.white.opacity(0.1))
                        .frame(height: 1),
                    alignment: .bottom
                )
                
                // Основной контент
                if showingGallery {
                    PresentationGalleryView(presentationManager: PresentationManager())
                } else {
                    ChatView(viewModel: viewModel)
                }
            }
        }
        .sheet(isPresented: $showingGallery) {
            PresentationGalleryView(presentationManager: PresentationManager())
        }
    }
}

struct NewPresentationSheet: View {
    @Binding var title: String
    @Binding var isPresented: Bool
    let presentationManager: PresentationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Название презентации", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Новая презентация")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        if !title.isEmpty {
                            presentationManager.createPresentation(title: title)
                            isPresented = false
                            title = ""
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}