//
//  AudioPlayerActor.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 12.06.24.
//

import AVFoundation
import Foundation

actor AudioPlayerActor {
    private(set) var player: AVAudioPlayer?

    private var audioPlayerDelegate: AudioPlayerDelegate
    private var continuation: CheckedContinuation<Void, Never>?

    init() {
        audioPlayerDelegate = AudioPlayerDelegate()
        audioPlayerDelegate.onFinish = { [unowned self] in
            Task { await self.cancel() }
        }
    }

    func playAudio(url: URL, shouldStartPlaying: Bool) async {
        audioLogger.info("Starting to play audio from URL: \(url.absoluteString)")
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = audioPlayerDelegate
            player?.prepareToPlay()
            if shouldStartPlaying { play() }
        } catch {
            audioLogger.error("Error playing audio: \(error.localizedDescription)")
        }
    }

    func play() {
        audioLogger.info("Audio playback started")
        player?.play()
    }

    func stop() {
        audioLogger.info("Stopping audio playback")
        player?.stop()
        cancel()
    }

    func pause() {
        audioLogger.info("Pausing audio playback")
        player?.pause()
    }

    func replay() {
        audioLogger.info("Replaying audio from the beginning")
        player?.currentTime = 0
        player?.play()
    }

    /// Ожидание завершения воспроизведения аудио.
    func waitForAudioToFinishPlaying() async {
        guard player?.isPlaying == true else {
            audioLogger.info("Player is not playing, nothing to wait for")
            return
        }

        await withCheckedContinuation { continuation in
            self.continuation = continuation
            audioLogger.info("Continuation set for waiting on audio finish: \(String(describing: self.continuation))")
        }
    }

    func isPlaying() async -> Bool {
        return player?.isPlaying ?? false
    }

    func currentTime() async -> TimeInterval {
        return player?.currentTime ?? 0
    }

    private func cancel() {
        audioLogger.info("Cancelling current operation: \(String(describing: self.continuation))")
        continuation?.resume()
        continuation = nil
    }
}

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onFinish: (() -> Void)?

    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully flag: Bool) {
        audioLogger.info("Audio finished playing successfully: \(flag)")
        onFinish?()
    }

    func audioPlayerDecodeErrorDidOccur(_: AVAudioPlayer, error: Error?) {
        audioLogger.error("Audio player decode error: \(error?.localizedDescription ?? "unknown error")")
        onFinish?()
    }
}
