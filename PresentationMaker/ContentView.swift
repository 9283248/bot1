import SwiftUI

struct ContentView: View {
    @StateObject private var presentationManager = PresentationManager()
    @State private var showingNewPresentation = false
    @State private var newPresentationTitle = ""
    
    var body: some View {
        NavigationView {
            PresentationGalleryView(presentationManager: presentationManager)
                .navigationTitle("Презентации")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingNewPresentation = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingNewPresentation) {
                    NewPresentationSheet(
                        title: $newPresentationTitle,
                        isPresented: $showingNewPresentation,
                        presentationManager: presentationManager
                    )
                }
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