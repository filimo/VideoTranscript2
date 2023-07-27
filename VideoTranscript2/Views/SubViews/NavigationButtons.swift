//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import SwiftUI

struct NavigationButtons: View {
    @ObservedObject var viewModel: SubtitleViewModel

    var body: some View {
        Group {
            Button(action: viewModel.prevSubtitle) {
                Text("Previous")
            }
            .keyboardShortcut(.leftArrow, modifiers: [])

            Button(action: viewModel.nextSubtitle) {
                Text("Next")
            }
            .keyboardShortcut(.rightArrow, modifiers: [])
        }
    }
}
