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
        let cacheURL = getCacheURL(for: text)
     
        do {
            if !FileManager.default.fileExists(atPath: cacheURL.path) {
                // Попробуем найти кэш с удаленным непригодным для чтения текстом
                let alternativeCacheURL = getCacheURL(for: text.removeUnreadableText())
                if FileManager.default.fileExists(atPath: alternativeCacheURL.path) {
                    return alternativeCacheURL
                } else {
                    // Генерация нового аудио
                    return try await generateNewAudio(text: text, cacheURL: cacheURL)
                }
            }
        } catch {
            handleNetworkError(error)
            
            return nil
        }
        
        return cacheURL
    }
    
    private func getCacheURL(for text: String) -> URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = text.sha256() + ".mp3"
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    private func generateNewAudio(text: String, cacheURL: URL) async throws -> URL {
        print("generateNewAudio:", text)
        
        let query = AudioSpeechQuery(model: .tts_1, input: text, voice: .alloy, responseFormat: .mp3, speed: 1.1)
        let audioResult = try await openAI.audioCreateSpeech(query: query)
        let audioData = audioResult.audio
        try audioData.write(to: cacheURL)
        
        return cacheURL
    }
    
    func handleNetworkError(_ error: Error) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                print("No internet connection. Please check your internet settings.")
            case .cannotFindHost:
                print("Cannot find host. Please check your URL.")
            case .timedOut:
                print("Request timed out. Please try again.")
            default:
                print("An error occurred: \(urlError.localizedDescription)")
            }
        } else if let openAIError = error as? OpenAIError {
            print("OpenAI error: \(openAIError.localizedDescription)")
        } else {
            print("Error creating speech: \(error.localizedDescription)")
        }
    }
}
