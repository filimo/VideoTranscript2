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

    var body: some View {
        HStack {
            VStack {
                playerView
                
                Text(viewModel.getCurrentOriginalSubtitle())
                    .font(.title3)
                    .textSelection(.enabled)
                
                Text(viewModel.getCurrentTranlatatedSubtitle())
                    .font(.title3)
                    .textSelection(.enabled)
                
                HStack {
                    if viewModel.showTwoSubtitlesColumns {
                        SubtitlesView(viewModel: viewModel, subtitles: viewModel.originalSubtitles)
                        
                        SubtitlesView(viewModel: viewModel, subtitles: viewModel.translatedSubtitles)
                        
                    } else {
                        SubtitlesView(viewModel: viewModel, subtitles: viewModel.subtitles2)
                    }
                }
                .frame(maxHeight: 250)
            }
            
            actionsView
        }
        .onChange(of: viewModel.playbackSpeed) { newValue in
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
            } else {
                // Provide a placeholder when there's no video loaded
                Rectangle()
                    .fill(Color.gray)
            }
        }
    }
    
    var actionsView: some View {
        VStack {
            LoadVideoButton(viewModel: viewModel)

            NavigationButtons(viewModel: viewModel)

            Stepper("Speed \(viewModel.playbackSpeed, specifier: "%.2f")", value: $viewModel.playbackSpeed, in: 0.5 ... 2.0, step: 0.05)
                .frame(maxWidth: 100)
            
        }
        .padding(.trailing, 5)
    }
}
