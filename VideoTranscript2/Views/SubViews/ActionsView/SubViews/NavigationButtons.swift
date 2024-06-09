//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import SwiftUI

struct NavigationButtons: View {
    @EnvironmentObject private var speechSynthesizer: OpenAISpeechSynthesizerStore
    @ObservedObject var viewModel: SubtitleStore

    var body: some View {
        GroupBox {
            Button("Previous") {
                speechSynthesizer.stop()
                viewModel.prevSubtitle()
            }
            .keyboardShortcut("a", modifiers: [])

            Button(action: {
                viewModel.isPlaying.toggle()
                if viewModel.isPlaying {
                    speechSynthesizer.play()
                } else {
                    speechSynthesizer.pause()
                }
            }) {
                Text(viewModel.isPlaying ? "Pause" : "Play")
            }
            .keyboardShortcut("s", modifiers: [])
//            .keyboardShortcut("c", modifiers: [])

//            Button(action: viewModel.nextSubtitleAndPlay) {
//                Text("Next&Play")
//            }
//            .keyboardShortcut("d", modifiers: [])

            Button("Next") {
                speechSynthesizer.stop()
                viewModel.nextSubtitle()
            }
            .keyboardShortcut("d", modifiers: [])

            Button("Repeat") {
                viewModel.repeatSubtitle()
                speechSynthesizer.replay()
            }
            .keyboardShortcut("r", modifiers: [])

        }
    }
}
