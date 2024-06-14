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
    @MainActor @Published var openAI_ApiToken = "none"

    let audioPlayer = AudioPlayerActor()

    private var audioCacheManager: AudioCacheManager? = nil

    func restoreApiToken() async {
        if let apiToken = KeychainHelper.retrieveTokenFromKeychain() {
            await MainActor.run {
                openAI_ApiToken = apiToken
            }
            audioCacheManager = AudioCacheManager(apiToken: apiToken)
        }
    }

    @MainActor func storeApiToken() async {
        KeychainHelper.storeTokenInKeychain(token: openAI_ApiToken)
        await restoreApiToken()
    }

    func synthesizeSpeech(textToSynthesize: String, isPlaying: Bool) async {
        guard let audioCacheManager else {
            audioLogger.warning("API token not found in Keychain")
            return
        }

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
