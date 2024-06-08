//
//  SpeechSynthesisViewModel.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 7.06.24.
//

//
//  SpeechSynthesisViewModel.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 7.06.24.
//

import AVFoundation
import OpenAI
import SwiftUI

@MainActor
class SpeechSynthesisViewModel: ObservableObject {
    @Published var speakingText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? {
        didSet {
            if let errorMessage {
                print("Error:", errorMessage)
            }
        }
    }
    
    private let openAI: OpenAI
    private var player: AVAudioPlayer?
    private var audioPlayerDelegate: AudioPlayerDelegate = .init()
    
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
        
        let cacheURL = getCacheURL(for: textToSynthesize)
        
        if FileManager.default.fileExists(atPath: cacheURL.path) {
            print("Fetching audio from cache for text: \(textToSynthesize)")
            await handleCachedAudio(at: cacheURL, textToSynthesize: textToSynthesize)
        } else {
            print("Fetching audio from API for text: \(textToSynthesize)")
            await handleNewAudio(textToSynthesize: textToSynthesize, cacheURL: cacheURL)
        }
        
        isLoading = false
    }
    
    private func handleCachedAudio(at cacheURL: URL, textToSynthesize: String) async {
        do {
            let audioData = try Data(contentsOf: cacheURL)
            speakingText = textToSynthesize
            await playAudio(data: audioData)
        } catch {
            setError(message: "Error playing cached audio: \(error.localizedDescription)")
        }
    }
    
    private func handleNewAudio(textToSynthesize: String, cacheURL: URL) async {
        let query = AudioSpeechQuery(model: .tts_1, input: textToSynthesize, voice: .alloy, responseFormat: .mp3, speed: 1.0)
        
        do {
            let audioResult = try await openAI.audioCreateSpeech(query: query)
            let audioData = audioResult.audio
            try audioData.write(to: cacheURL)
            speakingText = textToSynthesize
            await playAudio(data: audioData)
        } catch {
            handleNetworkError(error)
        }
    }
    
    private func getCacheURL(for text: String) -> URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = text.sha256() + ".mp3"
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    private func playAudio(data: Data) async {
        do {
            player = try AVAudioPlayer(data: data)
            player?.delegate = audioPlayerDelegate
            player?.play()
            await waitForAudioToFinishPlaying()
            speakingText = ""
        } catch {
            setError(message: "Error playing audio: \(error.localizedDescription)")
        }
    }
    
    private func waitForAudioToFinishPlaying() async {
        await withCheckedContinuation { continuation in
            audioPlayerDelegate.onFinish = {
                continuation.resume()
            }
        }
    }
    
    public func stop() {
        player?.stop()
        speakingText = ""
    }
    
    private func setError(message: String) {
        errorMessage = message
    }
    
    private func handleNetworkError(_ error: Error) {
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
