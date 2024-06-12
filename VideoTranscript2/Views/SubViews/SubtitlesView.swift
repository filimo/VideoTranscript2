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
                            onTap(subtitle: subtitle)
                        }
                }
            }
            .onChange(of: subtitleStore.activeId) { oldId, id  in
                print("subtitleStore.videoPlayer.currentTime: ", oldId, id)
                handleActiveIdChange(id, scrollProxy: scrollProxy)
            }
        }
    }
}
 
private extension SubtitlesView {
    func onTap(subtitle: Subtitle) {
        Task {
            await audioPlayer.stop()
    
            // Seek the player to the start time of the subtitle
            subtitleStore.videoPlayer.seek(startTime: subtitle.startTime)
        }
    }
    
    func handleActiveIdChange(_ id: Int, scrollProxy: ScrollViewProxy) {
        let isPlaying = subtitleStore.videoPlayer.isPlaying
            
        print("onReceive debounceActiveId", id)
        scrollProxy.scrollTo(id - 4, anchor: .top)
            
        currentTask?.cancel()
        currentTask = Task {
            await audioPlayer.stop()
            await waitForSpeechToEnd(isPlaying: isPlaying, id: id)
        }
    }
        
    func waitForSpeechToEnd(isPlaying: Bool, id: Int) async {
        print("waitForSpeechToEnd:", isPlaying, id)
        
        await audioPlayer.waitForAudioToFinishPlaying()
        
        if Task.isCancelled { return } // Проверка на отмену задачи
            
        if isPlaying {
            subtitleStore.videoPlayer.isPlaying = true
        }
            
        if let text = subtitleStore.translatedSubtitles.first(where: { $0.id == id })?.text {
            await speechSynthesizer.synthesizeSpeech(textToSynthesize: text)
        }
    }
}
