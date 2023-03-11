import Foundation

class LevelOneChain {
    enum Error: Swift.Error, CustomStringConvertible {
        case unknownWord

        var description: String {
            switch self {
            case .unknownWord:
                return "Unknown word"
            }
        }
    }

    private let continueWord: Double
    private var wordMapNormalized: [String:[String:Double]]

    init(words: [String], continueWord: Double) {
        self.continueWord = continueWord

        var wordMap = [String:[String:Int]]()
        for (word, next) in zip(words, words.dropFirst()) {
            if wordMap[word] == nil {
                wordMap[word] = [next:1]
            } else {
                if wordMap[word]![next] == nil {
                    wordMap[word]![next] = 1
                } else {
                    wordMap[word]![next]! += 1
                }
            }
        }
        self.wordMapNormalized = wordMap.mapValues { frequencies in
            let count = Double(frequencies.reduce(0) { $0 + $1.value })
            return frequencies.mapValues { freq in
                Double(freq) / count
            }
        }
    }

    private func chooseNext(word: String) -> String {
        let probabilities = wordMapNormalized[word]!
        let randomCutoff = Double.random(in: 0 ... 1)
        var runningProbability = 0.0
        for (word, prob) in probabilities {
            runningProbability += prob
            if randomCutoff <= runningProbability {
                return word
            }
        }
        fatalError("\(probabilities)")
    }

    func generate(from seed: String, max: Int) throws -> [String] {
        if wordMapNormalized[seed] == nil {
            throw LevelOneChain.Error.unknownWord
        }
        var array = [String]()
        var current = seed
        var i = 0
        while i < max && Double.random(in: 0 ... 1) < continueWord {
            let next = chooseNext(word: current)
            if current == "i" {
                current = "I"
            }
            array.append(current)
            current = next
            i += 1
        }
        return array
    }
}

func process(input: String, chain: LevelOneChain) {
    do {
        let result = try chain.generate(from: input, max: 30)
        print("reply: \(result.joined(separator: " ")).")
    } catch {
        print("error: \(error)")
    }
}

let rootPath = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
let morrisCorpusPath = rootPath.appendingPathComponent("output/morris-both.txt")

if var morrisCorpusText = try? String(contentsOf: morrisCorpusPath) {
    morrisCorpusText = morrisCorpusText.trimmingCharacters(in: .newlines)
    let morrisCorpusAttr = Attributes(text: morrisCorpusText)
    let chain = LevelOneChain(words: morrisCorpusAttr.words, continueWord: 0.99)

    print("Type 'q' to exit.")
    var input: String?
    repeat {
        print("Enter seed: ", terminator: "")
        input = readLine()
        if var input = input, input != "q" {
            input = input.trimmingCharacters(in: .whitespacesAndNewlines)
            process(input: input, chain: chain)
        }
    } while input != "q"
} else {
    print("error: Failed to locate with-catherine and/or with-sloper files")
}
