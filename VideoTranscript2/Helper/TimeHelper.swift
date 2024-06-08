//
//  TimeHelper.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 8.06.24.
//

import Foundation

struct TimeHelper {
    static func timeInterval(from timeString: String) -> TimeInterval? {
        let timeComponents = timeString.components(separatedBy: ":")
        guard timeComponents.count == 3 else { return nil }

        let hours = Double(timeComponents[0]) ?? 0
        let minutes = Double(timeComponents[1]) ?? 0
        let seconds = Double(timeComponents[2].replacingOccurrences(of: ",", with: ".")) ?? 0

        return hours * 3600 + minutes * 60 + seconds
    }
}
