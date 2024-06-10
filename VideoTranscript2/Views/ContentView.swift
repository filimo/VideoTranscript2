//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var subtitleStore: SubtitleStore

    var body: some View {
        HStack {
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

            ActionsView()
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
