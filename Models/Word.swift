import SwiftData
import Foundation

@Model
class Word {
    var text: String
    var definition: String
    var dateAdded: Date
    var suggestedWords: [SuggestedWord]
    
    init(text: String, definition: String) {
        self.text = text
        self.definition = definition
        self.dateAdded = Date()
        self.suggestedWords = []
    }
}

@Model
class SuggestedWord {
    var text: String
    var definition: String
    var dateGenerated: Date
    var sourceWord: Word?
    
    init(text: String, definition: String, sourceWord: Word? = nil) {
        self.text = text
        self.definition = definition
        self.dateGenerated = Date()
        self.sourceWord = sourceWord
    }
}