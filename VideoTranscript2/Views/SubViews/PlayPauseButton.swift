//
//  PlayPauseButton.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import SwiftUI

struct PlayPauseButton: View {
    @ObservedObject var viewModel: SubtitleViewModel

    var body: some View {
        Button(action: {
            viewModel.isPlaying.toggle()
        }) {
            Text(viewModel.isPlaying ? "Pause" : "Play")
        }
        .keyboardShortcut("p", modifiers: [])
    }
}

