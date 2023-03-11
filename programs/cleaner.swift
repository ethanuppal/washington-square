// Copyright (C) 2023 Ethan Uppal. All rights reserved.
import Foundation

let rootPath = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
let sourcePath = rootPath.appendingPathComponent("source.txt")
let destPath = rootPath.appendingPathComponent("output/source-morris.txt")

if let text = try? String(contentsOf: sourcePath) {
    let paragraphs = text.components(separatedBy: "\r\n\r\n")
    let dialogueParagraphs = paragraphs.filter {
        $0.contains("“") && ($0.contains("Morris") || $0.contains("Townsend"))
    }
    do {
        try dialogueParagraphs
            .drop { !$0.hasPrefix("So Catherine saw Mr. Townsend alone") }
            .joined(separator: "\n\n")
            .write(to: destPath, atomically: true, encoding: .utf8)
    } catch {
        print("error: \(error)")
    }
} else {
    print("error: Failed to locate source.txt file")
}
