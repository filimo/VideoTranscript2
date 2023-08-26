//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import AVKit
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SubtitleViewModel()
    @State private var playbackSpeed: Double = 1.0

    var body: some View {
        VStack {
            playerView

            Text(viewModel.getCurrentOriginalSubtitle())
                .font(.title3)
                .textSelection(.enabled)

            Text(viewModel.getCurrentTranlatatedSubtitle())
                .font(.title3)
                .textSelection(.enabled)

            HStack {
                LoadVideoButton(viewModel: viewModel)

                Divider()
                    .fixedSize()

                PlayPauseButton(viewModel: viewModel)

                NavigationButtons(viewModel: viewModel)

                Slider(value: $playbackSpeed, in: 0.5 ... 2.0, step: 0.1) {
                    Text("Speed \(playbackSpeed, specifier: "%.1f")")
                }
                .frame(maxWidth: 200)
            }
            HStack {
                if viewModel.showTwoSubtitlesColumns {
                    SubtitlesView(viewModel: viewModel, subtitles: viewModel.originalSubtitles)

                    SubtitlesView(viewModel: viewModel, subtitles: viewModel.translatedSubtitles)

                } else {
                    SubtitlesView(viewModel: viewModel, subtitles: viewModel.subtitles2)
                }
            }
            .aspectRatio(3/1, contentMode: .fit)
        }
        .onChange(of: playbackSpeed) { newValue in
            viewModel.player?.rate = Float(newValue)
        }
        .onAppear {
            if let videoURL = viewModel.videoURL {
                viewModel.setPlayer(videoURL: videoURL)
            }
        }
    }

    var playerView: some View {
        Group {
            if let player = viewModel.player {
                VideoPlayer(player: viewModel.player)
            } else {
                // Provide a placeholder when there's no video loaded
                Rectangle()
                    .fill(Color.gray)
            }
        }
    }
}
