//
//  PlayerView.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 3.06.24.
//

import AVKit
import SwiftUI

struct PlayerView: View {
    let player: AVPlayer?

    var body: some View {
        Group {
            if let player = player {
                VideoPlayer(player: player)
            } else {
                // Provide a placeholder when there's no video loaded
                Rectangle()
                    .fill(Color.gray)
            }
        }
    }
}
