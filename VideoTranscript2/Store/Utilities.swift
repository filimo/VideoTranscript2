
//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import AppKit
import Foundation
import UniformTypeIdentifiers

@MainActor
func openFile(allowedContentTypes: [UTType]) async -> URL? {
    let panel = NSOpenPanel()
    panel.allowedContentTypes = allowedContentTypes
    let result = await panel.begin()
    if result == .OK, let url = panel.url {
        return url
    } else {
        return nil
    }
}

func loadSRT(from url: URL) async throws -> [Subtitle] {
    let (data, _) = try await URLSession.shared.data(from: url)
    guard let srtContent = String(data: data, encoding: .utf8) else {
        throw URLError(.badServerResponse)
    }
    return parseSRTContent(srtContent)
}

func parseSRTContent(_ content: String) -> [Subtitle] {
    let lines = content.components(separatedBy: "\n")
    var subtitles: [Subtitle] = []
    var currentIndex = 0

    while currentIndex < lines.count {
        guard let id = Int(lines[currentIndex]) else { break }
        let time = lines[currentIndex + 1]
        let text = lines[currentIndex + 2]

        let times = time.components(separatedBy: " --> ")
        guard let startTime = timeInterval(from: times[0]),
              let endTime = timeInterval(from: times[1]) else { break }

        subtitles.append(Subtitle(id: id, startTime: startTime, endTime: endTime, text: text))
        currentIndex += 4 // Skip to the next subtitle (each subtitle takes up 4 lines)
    }

    return subtitles
}

func timeInterval(from timeString: String) -> TimeInterval? {
    let timeComponents = timeString.components(separatedBy: ":")
    guard timeComponents.count == 3 else { return nil }

    let hours = Double(timeComponents[0]) ?? 0
    let minutes = Double(timeComponents[1]) ?? 0
    let seconds = Double(timeComponents[2].replacingOccurrences(of: ",", with: ".")) ?? 0

    return hours * 3600 + minutes * 60 + seconds
}
