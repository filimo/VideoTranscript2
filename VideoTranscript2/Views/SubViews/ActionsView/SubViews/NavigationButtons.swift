//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import SwiftUI

struct NavigationButtons: View {
    @EnvironmentObject private var speechSynthesizer: OpenAISpeechSynthesizerStore
    @EnvironmentObject private var subtitleStore: SubtitleStore

    var body: some View {
        GroupBox {
            Button("Previous") {
                Task {
                    await speechSynthesizer.audioPlayer.stop()
                    subtitleStore.prevSubtitle()
                }
            }
            .keyboardShortcut("a", modifiers: [])

            Button(action: {
                subtitleStore.videoPlayer.isPlaying.toggle()
                if subtitleStore.videoPlayer.isPlaying {
                    Task {
                        await speechSynthesizer.audioPlayer.play()
                    }
                } else {
                    Task {
                        await speechSynthesizer.audioPlayer.pause()
                    }
                }
            }) {
                Text(subtitleStore.videoPlayer.isPlaying ? "Pause" : "Play")
            }
            .keyboardShortcut("s", modifiers: [])
//            .keyboardShortcut("c", modifiers: [])

//            Button(action: viewModel.nextSubtitleAndPlay) {
//                Text("Next&Play")
//            }
//            .keyboardShortcut("d", modifiers: [])

            Button("Next") {
                Task {
                    await speechSynthesizer.audioPlayer.stop()
                    subtitleStore.nextSubtitle()
                }
            }
            .keyboardShortcut("d", modifiers: [])

            Button("Repeat origin") {
                subtitleStore.repeatSubtitle()
            }
            .keyboardShortcut("e", modifiers: [])

            Button("Repeat translate") {
                Task {
                    await speechSynthesizer.audioPlayer.replay()
                }
            }
            .keyboardShortcut("r", modifiers: [])
        }
    }
}
