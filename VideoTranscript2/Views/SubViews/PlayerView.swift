//
//  PlayerView.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 3.06.24.
//

import AVKit
import SwiftUI

struct PlayerView: View {
    @StateObject private var playerObserver = AVPlayerObserver()
    let player: AVPlayer?

    var body: some View {
        Group {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        playerObserver.observe(player: player)
                    }
                    .onDisappear {
                        playerObserver.allowSleep()
                    }
            } else {
                // Provide a placeholder when there's no video loaded
                Rectangle()
                    .fill(Color.gray)
            }
        }
    }
}

