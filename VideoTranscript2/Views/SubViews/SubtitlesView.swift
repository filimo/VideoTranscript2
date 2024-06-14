//
//  SubtitlesView.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import Combine
import os
import SwiftUI

struct SubtitlesView: View {
    @EnvironmentObject private var speechSynthesizer: OpenAISpeechSynthesizerStore
    @EnvironmentObject private var subtitleStore: SubtitleStore

    var subtitles: [Subtitle]

    @State private var currentTask: Task<Void, Never>? = nil

    var body: some View {
        ScrollViewReader { scrollProxy in
            VStack {
                List(subtitles) { subtitle in
                    Text(subtitle.text)
                        .font(.body)
                        .id(subtitle.id)
                        .underline(subtitle.id == subtitleStore.activeId)
                        .onTapGesture {
                            onTap(subtitle: subtitle)
                        }
                }
            }
            .onChange(of: subtitleStore.activeId) { oldId, id in
                subtitlesLogger.info("subtitleStore.videoPlayer.currentTime: \(oldId) \(id)")
                handleActiveIdChange(id, scrollProxy: scrollProxy)
            }
        }
    }
}

private extension SubtitlesView {
    func onTap(subtitle: Subtitle) {
        Task {
            await speechSynthesizer.audioPlayer.stop()

            // Seek the player to the start time of the subtitle
            subtitleStore.videoPlayer.seek(startTime: subtitle.startTime)
        }
    }

    func handleActiveIdChange(_ id: Int, scrollProxy: ScrollViewProxy) {
        let isVideoPlaying = subtitleStore.videoPlayer.isPlaying

        // Логируем изменение активного идентификатора
        subtitlesLogger.info("onReceive debounceActiveId \(id)")

        // Прокручиваем к новому идентификатору
        scrollProxy.scrollTo(id - 4, anchor: .top)

        // Отменяем текущую задачу, если она существует
        currentTask?.cancel()
        currentTask = Task {
            if isVideoPlaying {
                await handleSpeechCompletion(isPlaying: isVideoPlaying, id: id)
            } else {
                if let text = subtitleStore.translatedSubtitles.first(where: { $0.id == id })?.text {
                    await synthesizeAndPlaySpeech(text, isPlaying: isVideoPlaying)
                }
            }
        }
    }

    func handleSpeechCompletion(isPlaying: Bool, id: Int) async {
        subtitlesLogger.info("handleSpeechCompletion: \(isPlaying) \(id)")

        subtitleStore.videoPlayer.isPlaying = false

        if Task.isCancelled { return }

        await speechSynthesizer.audioPlayer.waitForAudioToFinishPlaying()

        if isPlaying {
            subtitleStore.videoPlayer.isPlaying = true
        }

        if let text = subtitleStore.translatedSubtitles.first(where: { $0.id == id })?.text {
            await synthesizeAndPlaySpeech(text, isPlaying: isPlaying)
        }
    }

    func synthesizeAndPlaySpeech(_ text: String, isPlaying: Bool) async {
        await speechSynthesizer.synthesizeSpeech(textToSynthesize: text, isPlaying: isPlaying)
    }
}
