//
//  OpenAISpeechSynthesizerStore.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 7.06.24.
//

import AVFAudio
import OpenAI
import SwiftUI

let audioPlayer = AudioPlayerActor()

actor OpenAISpeechSynthesizerStore: ObservableObject {
    private let audioCacheManager: AudioCacheManager

    init() {
        guard let apiToken = KeychainHelper.retrieveTokenFromKeychain() else {
            fatalError("API token not found in Keychain")
        }
        audioCacheManager = AudioCacheManager(apiToken: apiToken)
    }

    func synthesizeSpeech(textToSynthesize: String) async {
        guard !textToSynthesize.isEmpty else { return }

        logger.info("Getting audio for text: \(textToSynthesize)")
        if let cacheURL = await audioCacheManager.getOrGenerateAudio(for: textToSynthesize) {
            await audioPlayer.playAudio(url: cacheURL)
        }
    }
}
