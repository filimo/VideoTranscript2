//
//  PlayerWithSubtitlesView.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 10.06.24.
//
import SwiftUI

struct PlayerWithSubtitlesView: View {
    @EnvironmentObject private var subtitleStore: SubtitleStore

    var body: some View {
        VStack {
            PlayerView(player: subtitleStore.player)

            Text(subtitleStore.getCurrentOriginalSubtitle())
                .font(.title3)
                .textSelection(.enabled)

            Text(subtitleStore.getCurrentTranlatatedSubtitle())
                .font(.title3)
                .textSelection(.enabled)

            HStack {
                if subtitleStore.showTwoSubtitlesColumns {
                    SubtitlesView(subtitles: subtitleStore.originalSubtitles)

                    SubtitlesView(subtitles: subtitleStore.translatedSubtitles)

                } else {
                    SubtitlesView(subtitles: subtitleStore.subtitles2)
                }
            }
            .frame(maxHeight: 250)
        }
        .onChange(of: subtitleStore.playbackSpeed) { newValue in
            subtitleStore.player?.rate = Float(newValue)
        }
        .onAppear {
            if let videoURL = subtitleStore.videoURL {
                subtitleStore.setPlayer(videoURL: videoURL)
            }
        }
    }
}