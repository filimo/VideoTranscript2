//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import SwiftUI

struct NavigationButtons: View {
    @ObservedObject var viewModel: SubtitleStore

    var body: some View {
        GroupBox {
            Button(action: viewModel.prevSubtitle) {
                Text("Previous")
            }
            .keyboardShortcut("a", modifiers: [])

            Button(action: {
                viewModel.isPlaying.toggle()
            }) {
                Text(viewModel.isPlaying ? "Pause" : "Play")
            }
            .keyboardShortcut("s", modifiers: [])
//            .keyboardShortcut("c", modifiers: [])

//            Button(action: viewModel.nextSubtitleAndPlay) {
//                Text("Next&Play")
//            }
//            .keyboardShortcut("d", modifiers: [])

            Button(action: viewModel.nextSubtitle) {
                Text("Next")
            }
            .keyboardShortcut("d", modifiers: [])

            Button(action: viewModel.repeatSubtitle) {
                Text("Repeat")
            }
            .keyboardShortcut(.return, modifiers: [])
        }
    }
}
