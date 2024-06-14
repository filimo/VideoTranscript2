//
//  SubtitleHelper.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 8.06.24.
//
import Foundation

enum SubtitleHelper {
    static func loadSRT(from url: URL) async throws -> [Subtitle] {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let srtContent = String(data: data, encoding: .utf8) else {
            throw URLError(.badServerResponse)
        }
        return parseSRTContent(srtContent)
    }

    static func parseSRTContent(_ content: String) -> [Subtitle] {
        let lines = content.components(separatedBy: "\n")
        var subtitles: [Subtitle] = []
        var currentIndex = 0

        while currentIndex < lines.count {
            guard let id = Int(lines[currentIndex]) else { break }
            let time = lines[currentIndex + 1]
            let text = lines[currentIndex + 2]

            let times = time.components(separatedBy: " --> ")
            guard let startTime = TimeHelper.timeInterval(from: times[0]),
                  let endTime = TimeHelper.timeInterval(from: times[1]) else { break }

            subtitles.append(Subtitle(id: id, startTime: startTime, endTime: endTime, text: text))
            currentIndex += 4 // Skip to the next subtitle (each subtitle takes up 4 lines)
        }

        return subtitles
    }
}
