//
//  OpenAISpeechSynthesizerStore.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 7.06.24.
//

import AVFoundation
import OpenAI
import SwiftUI

@MainActor
class OpenAISpeechSynthesizerStore: ObservableObject {
    @Published var speakingText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? {
        didSet {
            if let errorMessage {
                print("Error:", errorMessage)
            }
        }
    }

    @Published var isCreatingSpeech: Bool = false
    
    private let openAI: OpenAI
    private var player: AVAudioPlayer?
    private var audioPlayerDelegate: AudioPlayerDelegate = .init()
    
    private var continuation: CheckedContinuation<Void, Never>?
    
    init() {
        guard let apiToken = KeychainHelper.retrieveTokenFromKeychain() else {
            fatalError("API token not found in Keychain")
        }
        self.openAI = OpenAI(apiToken: apiToken)
    }
    
    func synthesizeSpeech(textToSynthesize: String) async {
        guard !textToSynthesize.isEmpty else { return }
            
        isLoading = true
        errorMessage = nil
        
        var cacheURL = getCacheURL(for: textToSynthesize)
        
        if !FileManager.default.fileExists(atPath: cacheURL.path) {
            // Попробуем найти кэш с удаленным непригодным для чтения текстом
            cacheURL = getCacheURL(for: textToSynthesize.removeUnreadableText())
        }
        
        if FileManager.default.fileExists(atPath: cacheURL.path) {
            print("Fetching audio from cache for text: \(textToSynthesize)")
            await handleCachedAudio(at: cacheURL, textToSynthesize: textToSynthesize)
        } else {
            print("Fetching audio from API for text: \(textToSynthesize)")
            await handleNewAudio(textToSynthesize: textToSynthesize, cacheURL: cacheURL)
        }
        
        isLoading = false
    }

    func stop() {
        player?.stop()
        speakingText = ""
    }
    
    func replay() {
        player?.currentTime = 0
        player?.play()
    }

    func pause() {
        player?.pause()
    }
    
    func play() {
        player?.play()
    }
    
    func waitForAudioToFinishPlaying() async {
        guard !speakingText.isEmpty else { return }
        
        continuation?.resume()
        continuation = nil
        
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            audioPlayerDelegate.onFinish = { [weak self] in
                self?.audioPlayerFinishedPlaying()
            }
        }
    }
}

private extension OpenAISpeechSynthesizerStore {
    func handleCachedAudio(at cacheURL: URL, textToSynthesize: String) async {
        do {
            let audioData = try Data(contentsOf: cacheURL)
            speakingText = textToSynthesize
            await playAudio(data: audioData)
        } catch {
            setError(message: "Error playing cached audio: \(error.localizedDescription)")
        }
    }
    
    func handleNewAudio(textToSynthesize: String, cacheURL: URL) async {
        let query = AudioSpeechQuery(model: .tts_1, input: textToSynthesize, voice: .alloy, responseFormat: .mp3, speed: 1.1)
        
        do {
            isCreatingSpeech = true
            
            let audioResult = try await openAI.audioCreateSpeech(query: query)
            let audioData = audioResult.audio
            
            try audioData.write(to: cacheURL)
            
            isCreatingSpeech = false
            speakingText = textToSynthesize
            
            await playAudio(data: audioData)
        } catch {
            handleNetworkError(error)
        }
    }
    
    func getCacheURL(for text: String) -> URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = text.sha256() + ".mp3"
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    func playAudio(data: Data) async {
        do {
            player = try AVAudioPlayer(data: data)
            player?.delegate = audioPlayerDelegate
            player?.play()
            await waitForAudioToFinishPlaying()
        } catch {
            setError(message: "Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerFinishedPlaying() {
        if let continuation = continuation {
            self.continuation = nil
            speakingText = ""
            continuation.resume()
        }
    }
    
    func setError(message: String) {
        errorMessage = message
    }
    
    func handleNetworkError(_ error: Error) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                setError(message: "No internet connection. Please check your internet settings.")
            case .cannotFindHost:
                setError(message: "Cannot find host. Please check your URL.")
            case .timedOut:
                setError(message: "Request timed out. Please try again.")
            default:
                setError(message: "An error occurred: \(urlError.localizedDescription)")
            }
        } else if let openAIError = error as? OpenAIError {
            setError(message: "OpenAI error: \(openAIError.localizedDescription)")
        } else {
            setError(message: "Error creating speech: \(error.localizedDescription)")
        }
    }
}

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onFinish: (() -> Void)?
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish?()
    }
}
