import SwiftUI
import SwiftData

@main
struct WordsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Word.self, SuggestedWord.self])
    }
}

struct ContentView: View {
    @Query private var words: [Word]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            VStack {
                if let firstWord = words.first {
                    WordDetailView(word: firstWord)
                } else {
                    // Demo word for testing
                    Button("Add Sample Word") {
                        addSampleWord()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Words App")
        }
    }
    
    private func addSampleWord() {
        let sampleWord = Word(
            text: "Serendipity",
            definition: "The occurrence and development of events by chance in a happy or beneficial way"
        )
        modelContext.insert(sampleWord)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Word.self, SuggestedWord.self], inMemory: true)
}