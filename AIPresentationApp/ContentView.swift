import SwiftUI

struct ContentView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var presentationViewModel = PresentationViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ChatView()
                .environmentObject(chatViewModel)
                .environmentObject(presentationViewModel)
                .tabItem {
                    Image(systemName: "message")
                    Text("Чат")
                }
                .tag(0)
            
            PresentationsListView()
                .environmentObject(presentationViewModel)
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Презентации")
                }
                .tag(1)
        }
        .accentColor(.blue)
    }
}

struct PresentationsListView: View {
    @EnvironmentObject var presentationViewModel: PresentationViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(presentationViewModel.presentations.indices, id: \.self) { index in
                    let presentation = presentationViewModel.presentations[index]
                    NavigationLink(destination: PresentationView(presentation: presentation)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(presentation.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("\(presentation.slides.count) слайдов • \(presentation.duration) мин")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(presentation.theme)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deletePresentations)
            }
            .navigationTitle("Мои презентации")
            .listStyle(PlainListStyle())
        }
    }
    
    private func deletePresentations(offsets: IndexSet) {
        for index in offsets {
            presentationViewModel.deletePresentation(at: index)
        }
    }
}

#Preview {
    ContentView()
}