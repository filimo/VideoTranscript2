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
    @ObservedObject var viewModel: SubtitleStore
    var subtitles: [Subtitle]
    
    @State private var currentTask: Task<Void, Never>? = nil
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            VStack {
                List(subtitles) { subtitle in
                    Text(subtitle.text)
                        .font(.body)
                        .id(subtitle.id)
                        .underline(subtitle.id == viewModel.activeId)
                        .onTapGesture {
                            speechSynthesizer.stop()
                            viewModel.isPlaying = false
                            
                            // Seek the player to the start time of the subtitle
                            viewModel.seek(startTime: subtitle.startTime)
                            viewModel.activeId = subtitle.id
                        }
                }
            }
            .onReceive(viewModel.debounceActiveId) { id in
                handleActiveIdChange(id, scrollProxy: scrollProxy)
            }
        }
    }
}
 
private extension SubtitlesView {
    func handleActiveIdChange(_ id: Int, scrollProxy: ScrollViewProxy) {
        let isPlaying = viewModel.isPlaying
            
        print("onReceive debounceActiveId", id)
        scrollProxy.scrollTo(id - 4, anchor: .top)
            
        if speechSynthesizer.speakingText != "" {
            viewModel.isPlaying = false
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
            viewModel.isPlaying = true
        }
            
        if let text = viewModel.translatedSubtitles.first(where: { $0.id == id })?.text {
            speechSynthesizer.stop()
            await speechSynthesizer.synthesizeSpeech(textToSynthesize: text)
        }
    }
}
