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
                
            Text(viewModel.getCurrentTranlatatedSubtitle())
                .font(.title3)

            HStack {
                LoadVideoButton(viewModel: viewModel)

                PlayPauseButton(viewModel: viewModel)

                NavigationButtons(viewModel: viewModel)

                Slider(value: $playbackSpeed, in: 0.5 ... 2.0, step: 0.1) {
                    Text("Speed \(playbackSpeed, specifier: "%.1f")")
                }
                .frame(maxWidth: 200)
            }
            HStack {
                SubtitlesView(viewModel: viewModel, subtitles: $viewModel.originalSubtitles, title: "Original")
                SubtitlesView(viewModel: viewModel, subtitles: $viewModel.translatedSubtitles, title: "Translated")
            }
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
                VideoPlayer(player: player)
//                    .frame(height: 200)
            } else {
                // Provide a placeholder when there's no video loaded
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 200)
            }
        }
    }
}
