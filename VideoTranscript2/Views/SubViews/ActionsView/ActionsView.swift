//
//  ActionsView.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 3.06.24.
//

import SwiftUI

struct ActionsView: View {
    @EnvironmentObject private var speechSynthesizer: OpenAISpeechSynthesizerStore
    @EnvironmentObject private var subtitleStore: SubtitleStore

    var body: some View {
        VStack {
            LoadVideoButton()

            NavigationButtons()

            Stepper("Speed \(subtitleStore.videoPlayer.playbackSpeed, specifier: "%.2f")", value: subtitleStore.videoPlayer.$playbackSpeed, in: 0.5 ... 2.0, step: 0.05)
                .frame(maxWidth: 100)

//            if speechSynthesizer.isCreatingSpeech {
//                Text("Creating\nSpeech...")
//                    .foregroundStyle(.red)
//            }
        }
        .padding(.trailing, 5)
    }
}
