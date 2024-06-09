//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import SwiftUI

struct NavigationButtons: View {
    @EnvironmentObject private var speechSynthesizer: OpenAISpeechSynthesizerStore
    @ObservedObject var subtitleStore: SubtitleStore

    var body: some View {
        GroupBox {
            Button("Previous") {
                speechSynthesizer.stop()
                subtitleStore.prevSubtitle()
            }
            .keyboardShortcut("a", modifiers: [])

            Button(action: {
                subtitleStore.isPlaying.toggle()
                if subtitleStore.isPlaying {
                    speechSynthesizer.play()
                } else {
                    speechSynthesizer.pause()
                }
            }) {
                Text(subtitleStore.isPlaying ? "Pause" : "Play")
            }
            .keyboardShortcut("s", modifiers: [])
//            .keyboardShortcut("c", modifiers: [])

//            Button(action: viewModel.nextSubtitleAndPlay) {
//                Text("Next&Play")
//            }
//            .keyboardShortcut("d", modifiers: [])

            Button("Next") {
                speechSynthesizer.stop()
                subtitleStore.nextSubtitle()
            }
            .keyboardShortcut("d", modifiers: [])

            Button("Repeat origin") {
                subtitleStore.repeatSubtitle()
            }
            .keyboardShortcut("e", modifiers: [])

            Button("Repeat translate") {
                speechSynthesizer.replay()
            }
            .keyboardShortcut("r", modifiers: [])
        }
    }
}
