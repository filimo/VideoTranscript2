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

    @State var playbackRate: Double = 1

    var body: some View {
        VStack {
            LoadVideoButton()

            NavigationButtons()

            Stepper("Speed \(playbackRate, specifier: "%.2f")", value: $playbackRate, in: 0.5 ... 2.0, step: 0.05)
                .onChange(of: playbackRate, { oldValue, newValue in
                    subtitleStore.videoPlayer.playbackRate = newValue
                })
                .onAppear {
                    playbackRate = subtitleStore.videoPlayer.playbackRate
                }
                .frame(maxWidth: 100)

            if speechSynthesizer.isCreatingSpeech {
                Text("Creating\nSpeech...")
                    .foregroundStyle(.red)
            }
        }
        .padding(.trailing, 5)
    }
}
