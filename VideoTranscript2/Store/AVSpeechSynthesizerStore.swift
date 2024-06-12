//
//  AVSpeechSynthesizerStore.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 2.06.24.
//
import AVFoundation
import Combine

@Observable
class AVSpeechSynthesizerStore {
    private var synthesizer = AVSpeechSynthesizer()
    private let voice: AVSpeechSynthesisVoice?
    
    private var cancellables = Set<AnyCancellable>()
    
    var speakingText: String = ""
    
    init() {
        self.voice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.name == "Milena" && $0.quality == .enhanced })
        
        // Observe the isSpeaking property
        synthesizer.publisher(for: \.isSpeaking)
            .sink { [weak self] isSpeaking in
                if !isSpeaking {
                    self?.speakingText = ""
                }
            }
            .store(in: &cancellables)
    }
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        synthesizer.speak(utterance)
        speakingText = text
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        speakingText = ""
    }
}


