// Copyright (C) 2023 Ethan Uppal. All rights reserved.
import Foundation

class Attributes {
    struct Summary {
        let wordCount: Int
        let wordFrequencies: [String:Int]
        let specialPuncCounts: [Character:Int]
    }

    static private let splitCharacters = "\n`~1!2@3#4$5%6^7&8*9(0)-_=+[{]}\\|;:'\",<.>/?']` —"
    static let specialPunctuations: [Character] = ["!", "?", "."]

    private let words: [String]
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

struct ZInterval: CustomStringConvertible {
    let pointEstimate: Double
    let standardDeviation: Double
    let zStar: Double
    let marginOfError: Double
    let bounds: ClosedRange<Double>

    init(p1: Double, p2: Double, n1: Double, n2: Double, zStar: Double) {
        self.pointEstimate = p1 - p2
        let pC = (p1 * n1 + p2 * n2) / (n1 + n2)
        self.standardDeviation = sqrt(pC * (1 - pC) * (1 / n1 + 1 / n2))
        self.zStar = zStar
        self.marginOfError = self.zStar * self.standardDeviation
        self.bounds = (self.pointEstimate - self.marginOfError) ... (self.pointEstimate + self.marginOfError)
    }

    var isSignificant: Bool {
        return !bounds.contains(0)
    }
    var cohenD: Double {
        return pointEstimate / standardDeviation
    }

    var description: String {
        return "[\(bounds.lowerBound), \(bounds.upperBound)]"
    }
}

let rootPath = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
let withCatherinePath = rootPath.appendingPathComponent("data/morris-with-catherine.txt")
let withSloperPath = rootPath.appendingPathComponent("data/morris-with-sloper.txt")

if var withCatherineText = try? String(contentsOf: withCatherinePath),
    var withSloperText = try? String(contentsOf: withSloperPath) {

    withCatherineText = withCatherineText.trimmingCharacters(in: .newlines)
    withSloperText = withSloperText.trimmingCharacters(in: .newlines)

    let withCatherineAttr = Attributes(text: withCatherineText)
    let withSloperAttr = Attributes(text: withSloperText)

    compareAttributes(withCatherineAttr, withSloperAttr)
} else {
    print("error: Failed to locate with-catherine and/or with-sloper files")
}

func compareAttributes(
    _ withCatherineAttr: Attributes,
    _ withSloperAttr: Attributes
) {
    let withCatherineSum = withCatherineAttr.generateSummary()
    let withSloperSum = withSloperAttr.generateSummary()

    let n1 = Double(withCatherineSum.wordCount)
    let n2 = Double(withSloperSum.wordCount)

    // Intervals for proportion of words that have special punctuations
    for specialPunc in Attributes.specialPunctuations {
        let x1 = withCatherineSum.specialPuncCounts[specialPunc]!
        let x2 = withSloperSum.specialPuncCounts[specialPunc]!
        let p1 = Double(x1) / n1
        let p2 = Double(x2) / n2
        let interval = ZInterval(p1: p1, p2: p2, n1: n1, n2: n2, zStar: 1.96)
        print("'\(specialPunc)': \(interval)\n\td=\(interval.cohenD)")
    }

    // Intervals for word frequency
    let withCatherineFreqs = withCatherineSum.wordFrequencies.mapValues {
        Double($0) / n1
    }
    let withSloperFreqs = withSloperSum.wordFrequencies.mapValues {
        Double($0) / n2
    }

    // Combine the keys to iterate in union
    var wordsUnion = Set<String>()
    for (word, _) in withCatherineFreqs {
        wordsUnion.insert(word)
    }
    for (word, _) in withSloperFreqs {
        wordsUnion.insert(word)
    }

    for word in wordsUnion {
        let p1 = withCatherineFreqs[word] ?? 0
        let p2 = withSloperFreqs[word] ?? 0
        let interval = ZInterval(p1: p1, p2: p2, n1: n1, n2: n2, zStar: 1.96)
        if interval.isSignificant {
            print("\"\(word)\": \(interval)\n\td=\(interval.cohenD)")
        }
    }
}
