//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import Combine
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
                            speechSynthesizer.stop()
                            subtitleStore.isPlaying = false
                            
                            // Seek the player to the start time of the subtitle
                            subtitleStore.seek(startTime: subtitle.startTime)
                            subtitleStore.activeId = subtitle.id
                        }
                }
            }
            .onReceive(subtitleStore.debounceActiveId) { id in
                handleActiveIdChange(id, scrollProxy: scrollProxy)
            }
        }
    }
}
 
private extension SubtitlesView {
    func handleActiveIdChange(_ id: Int, scrollProxy: ScrollViewProxy) {
        let isPlaying = subtitleStore.isPlaying
            
        print("onReceive debounceActiveId", id)
        scrollProxy.scrollTo(id - 4, anchor: .top)
            
        if speechSynthesizer.speakingText != "" {
            subtitleStore.isPlaying = false
        }
            
        currentTask?.cancel() // Отмена предыдущей задачи, если она существует
        currentTask = Task {
            await waitForSpeechToEnd(isPlaying: isPlaying, id: id)
        }
    }
        
    func waitForSpeechToEnd(isPlaying: Bool, id: Int) async {
        await speechSynthesizer.waitForAudioToFinishPlaying()
        
        if Task.isCancelled { return }  // Проверка на отмену задачи
            
        if isPlaying {
            subtitleStore.isPlaying = true
        }
            
        if let text = subtitleStore.translatedSubtitles.first(where: { $0.id == id })?.text {
            speechSynthesizer.stop()
            await speechSynthesizer.synthesizeSpeech(textToSynthesize: text)
        }
    }
}
