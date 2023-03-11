// Copyright (C) 2023 Ethan Uppal. All rights reserved.
class Attributes {
    struct Summary {
        let wordCount: Int
        let wordFrequencies: [String:Int]
        let specialPuncCounts: [Character:Int]
    }

    static private let splitCharacters = "\n`~1!2@3#4$5%6^7&8*9(0)-_=+[{]}\\|;:'\",<.>/?']` —"
    static let specialPunctuations: [Character] = ["!", "?", "."]

    let words: [String]
    private var specialPuncCounts = [Character:Int]()

    init(text: String) {
        // This code is very inefficient, but that is not the goal here.
        self.words = (text.split {
            Attributes.splitCharacters.contains($0)
        }).map { String($0).lowercased() }
        for specialPunc in Attributes.specialPunctuations {
            specialPuncCounts[specialPunc] = text.filter({
                $0 == specialPunc
            }).count
        }
    }

    func generateSummary() -> Summary {
        var wordFrequencies = [String:Int]()
        for word in words {
            if wordFrequencies[word] == nil {
                wordFrequencies[word] = 1
            } else {
                wordFrequencies[word]! += 1
            }
        }
        return Summary(
            wordCount: words.count,
            wordFrequencies: wordFrequencies,
            specialPuncCounts: specialPuncCounts
        )
    }
}
