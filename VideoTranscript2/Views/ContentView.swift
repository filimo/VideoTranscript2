//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SubtitleStore()

    var body: some View {
        HStack {
            VStack {
                PlayerView(player: viewModel.player)
                
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
            
            ActionsView(viewModel: viewModel)
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
}




