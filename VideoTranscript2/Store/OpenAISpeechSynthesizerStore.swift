//
//  OpenAISpeechSynthesizerStore.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 7.06.24.
//

import AVFAudio
import OpenAI
import SwiftUI

actor OpenAISpeechSynthesizerStore: ObservableObject {
    @MainActor @Published var isCreatingSpeech = false

    let audioPlayer = AudioPlayerActor()

    private let audioCacheManager: AudioCacheManager

    init() {
        guard let apiToken = KeychainHelper.retrieveTokenFromKeychain() else {
            fatalError("API token not found in Keychain")
        }
        audioCacheManager = AudioCacheManager(apiToken: apiToken)
    }

    func synthesizeSpeech(textToSynthesize: String, isPlaying: Bool) async {
        guard !textToSynthesize.isEmpty else { return }

        audioLogger.info("Getting audio for text: \(textToSynthesize)")

        var cacheURL = await audioCacheManager.getCacheURLIfExists(for: textToSynthesize)

        if cacheURL == nil {
            await MainActor.run { isCreatingSpeech = true }
            cacheURL = await audioCacheManager.generateAudio(for: textToSynthesize)
            await MainActor.run { isCreatingSpeech = false }
        }

        if let cacheURL {
            await audioPlayer.playAudio(url: cacheURL, shouldStartPlaying: isPlaying)
        }
    }
}
