//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import Combine
import SwiftUI

struct SubtitlesView: View {
    @StateObject private var speechSynthesizer = SpeechSynthesizer()
    @ObservedObject var viewModel: SubtitleViewModel
    var subtitles: [Subtitle]

    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        ScrollViewReader { scrollProxy in
            VStack {
                List(subtitles) { subtitle in
                    Text(subtitle.text)
                        .font(.body)
                        .id(subtitle.id)
                        .underline(subtitle.id == viewModel.activeId)
                        .onTapGesture {
                            // Seek the player to the start time of the subtitle
                            viewModel.seek(startTime: subtitle.startTime)
                            viewModel.activeId = subtitle.id
                        }
                }
            }
            .onReceive(viewModel.debounceActiveId) { id in
                let isPlaying = viewModel.isPlaying

                print("onReceive debounceActiveId", id)
                scrollProxy.scrollTo(id - 5, anchor: .top)

                if speechSynthesizer.speakingText != "" {
                    viewModel.isPlaying = false
                }

                speechSynthesizer.$speakingText
                    .filter { $0 == "" }
                    .delay(for: 0.5, scheduler: RunLoop.main)
                    .first()
                    .sink { _ in
                        if isPlaying { viewModel.isPlaying = true }
                        if let text = viewModel.translatedSubtitles.first(where: { $0.id == id })?.text {
                            speechSynthesizer.stop()
                            speechSynthesizer.speak(text: text.removeUnreadableText())
                        }
                    }
                    .store(in: &cancellables)
            }
        }
    }
}
