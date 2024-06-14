//
//  AudioCacheManager.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 12.06.24.
//
import AVFoundation
@preconcurrency import OpenAI

actor AudioCacheManager {
    private let openAI: OpenAI

    init(apiToken: String) {
        openAI = OpenAI(apiToken: apiToken)
    }

    func getOrGenerateAudio(for text: String) async -> URL? {
        do {
            if let cacheURL = getCacheURLIfExists(for: text) {
                return cacheURL
            } else {
                let cacheURL = getCacheURL(for: text)
                return try await generateNewAudio(text: text, cacheURL: cacheURL)
            }
        } catch {
            handleNetworkError(error)
            return nil
        }
    }

    func getCacheURLIfExists(for text: String) -> URL? {
        let cacheURL = getCacheURL(for: text)
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: cacheURL.path) {
            logger.info("Cache available for text: \(text)")
            return cacheURL
        }

        logger.info("Cache not found for text: \(text). Checking alternative.")
        let alternativeCacheURL = getCacheURL(for: text.removeUnreadableText())
        if fileManager.fileExists(atPath: alternativeCacheURL.path) {
            logger.info("Alternative cache available for text: \(text.removeUnreadableText())")
            return alternativeCacheURL
        }

        logger.info("Alternative cache not found for text: \(text.removeUnreadableText())")
        return nil
    }

    private func getCacheURL(for text: String) -> URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = text.sha256() + ".mp3"
        return cacheDirectory.appendingPathComponent(fileName)
    }

    private func generateNewAudio(text: String, cacheURL: URL) async throws -> URL {
        logger.info("Generating new audio for text: \(text)")

        let query = AudioSpeechQuery(model: .tts_1, input: text, voice: .alloy, responseFormat: .mp3, speed: 1.1)
        let audioResult: AudioSpeechResult
        do {
            audioResult = try await openAI.audioCreateSpeech(query: query)
        } catch {
            logger.error("Failed to create audio via OpenAI: \(error.localizedDescription)")
            throw error
        }

        do {
            let audioData = audioResult.audio
            try audioData.write(to: cacheURL)
        } catch {
            logger.error("Failed to write audio data to cache: \(error.localizedDescription)")
            throw error
        }

        logger.info("Successfully generated and cached audio for text: \(text)")
        return cacheURL
    }

    func handleNetworkError(_ error: Error) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                logger.error("No internet connection. Please check your internet settings.")
            case .cannotFindHost:
                logger.error("Cannot find host. Please check your URL.")
            case .timedOut:
                logger.error("Request timed out. Please try again.")
            default:
                logger.error("An error occurred: \(urlError.localizedDescription)")
            }
        } else if let openAIError = error as? OpenAIError {
            logger.error("OpenAI error: \(openAIError.localizedDescription)")
        } else {
            logger.error("Error creating speech: \(error.localizedDescription)")
        }
    }
}
