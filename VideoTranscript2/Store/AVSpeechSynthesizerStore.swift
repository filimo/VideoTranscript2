//
//  AVSpeechSynthesizerStore.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 2.06.24.
//
import AVFoundation

class AVSpeechSynthesizerStore: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private var synthesizer = AVSpeechSynthesizer()
    private let voice: AVSpeechSynthesisVoice?
    
    @Published var speakingText: String = ""
    
    override init() {
        self.voice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.name == "Milena" && $0.quality == .enhanced })
        super.init()
        synthesizer.delegate = self
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
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speakingText = ""
    }
}

