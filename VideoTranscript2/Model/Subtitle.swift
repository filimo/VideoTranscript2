
//
//  Subtitle.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import Foundation

struct Subtitle: Identifiable, Codable {
    let id: Int
    let startTime: TimeInterval
    let endTime: TimeInterval
    let text: String
}
