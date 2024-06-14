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

    func playAudio(url: URL) async {
        logger.info("Starting to play audio from URL: \(url.absoluteString)")
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = audioPlayerDelegate
            player?.prepareToPlay()
            play()
        } catch {
            logger.error("Error playing audio: \(error.localizedDescription)")
        }
    }

    func play() {
        logger.info("Audio playback started")
        player?.play()
    }

    func stop() {
        logger.info("Stopping audio playback")
        player?.stop()
        cancel()
    }

    func pause() {
        logger.info("Pausing audio playback")
        player?.pause()
    }

    func replay() {
        logger.info("Replaying audio from the beginning")
        player?.currentTime = 0
        player?.play()
    }

    /// Ожидание завершения воспроизведения аудио.
    func waitForAudioToFinishPlaying() async {
        guard player?.isPlaying == true else {
            logger.info("Player is not playing, nothing to wait for")
            return
        }

        await withCheckedContinuation { continuation in
            self.continuation = continuation
            logger.info("Continuation set for waiting on audio finish: \(String(describing: self.continuation))")
        }
    }

    func isPlaying() async -> Bool {
        return player?.isPlaying ?? false
    }

    func currentTime() async -> TimeInterval {
        return player?.currentTime ?? 0
    }

    private func cancel() {
        logger.info("Cancelling current operation: \(String(describing: self.continuation))")
        continuation?.resume()
        continuation = nil
    }
}

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onFinish: (() -> Void)?

    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully flag: Bool) {
        logger.info("Audio finished playing successfully: \(flag)")
        onFinish?()
    }

    func audioPlayerDecodeErrorDidOccur(_: AVAudioPlayer, error: Error?) {
        logger.error("Audio player decode error: \(error?.localizedDescription ?? "unknown error")")
        onFinish?()
    }
}
