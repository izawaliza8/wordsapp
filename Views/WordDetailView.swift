import SwiftUI
import SwiftData

struct WordDetailView: View {
    let word: Word
    @Environment(\.modelContext) private var modelContext
    @State private var magicSuggestService: MagicSuggestService?
    @State private var isGeneratingSuggestions = false
    @State private var showingSuggestions = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Main Word Section
                wordHeaderSection
                
                // Definition Section
                definitionSection
                
                // Magic Suggest Section
                magicSuggestSection
                
                // Suggested Words Section
                if !word.suggestedWords.isEmpty {
                    suggestedWordsSection
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
        .navigationTitle("Word Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupMagicSuggestService()
        }
    }
    
    // MARK: - View Components
    
    private var wordHeaderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(word.text)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .symbolEffect(.pulse, isActive: showingSuggestions)
            }
            
            Text("Added \(word.dateAdded.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical)
    }
    
    private var definitionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Definition", systemImage: "text.quote")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(word.definition)
                .font(.body)
                .lineSpacing(4)
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var magicSuggestSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Magic Suggest", systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Button(action: generateSuggestions) {
                HStack {
                    if isGeneratingSuggestions {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "wand.and.stars")
                            .symbolEffect(.bounce, value: showingSuggestions)
                    }
                    
                    Text(isGeneratingSuggestions ? "Generating..." : "Suggest Related Words")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .foregroundStyle(.white)
            }
            .disabled(isGeneratingSuggestions)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: showingSuggestions)
        }
    }
    
    private var suggestedWordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Related Words", systemImage: "link")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            LazyVStack(spacing: 12) {
                ForEach(word.suggestedWords.sorted(by: { $0.dateGenerated > $1.dateGenerated }), id: \.text) { suggestion in
                    SuggestedWordCard(suggestion: suggestion)
                }
            }
        }
        .opacity(showingSuggestions ? 1 : 0)
        .animation(.easeInOut(duration: 0.5), value: showingSuggestions)
    }
    
    // MARK: - Actions
    
    private func setupMagicSuggestService() {
        magicSuggestService = MagicSuggestService(modelContext: modelContext)
    }
    
    private func generateSuggestions() {
        guard let service = magicSuggestService else { return }
        
        isGeneratingSuggestions = true
        
        Task {
            do {
                let suggestions = try await service.suggestRelatedWords(for: word)
                
                await MainActor.run {
                    isGeneratingSuggestions = false
                    showingSuggestions = true
                }
            } catch {
                await MainActor.run {
                    isGeneratingSuggestions = false
                    // Handle error - could show alert or error state
                    print("Error generating suggestions: \(error)")
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct SuggestedWordCard: View {
    let suggestion: SuggestedWord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(suggestion.text)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(suggestion.dateGenerated.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Text(suggestion.definition)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(2)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WordDetailView(word: Word(
            text: "Serendipity",
            definition: "The occurrence and development of events by chance in a happy or beneficial way"
        ))
    }
    .modelContainer(for: [Word.self, SuggestedWord.self], inMemory: true)
}