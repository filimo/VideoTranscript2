//
//  AudioPlayerActor.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 12.06.24.
//

import AVFoundation
import Foundation

actor AudioPlayerActor {
    private var player: AVAudioPlayer?
    
    private var audioPlayerDelegate: AudioPlayerDelegate = .init()
    private var continuation: CheckedContinuation<Void, Never>?
    
    func playAudio(url: URL) async {
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
        player?.play()
    }
    
    func stop() {
        logger.info("Called AVAudioPlayer.stop()")
        player?.stop()
        cancel()
    }
    
    func pause() {
        player?.pause()
    }
    
    func replay() {
        player?.currentTime = 0
        player?.play()
    }
    
    func waitForAudioToFinishPlaying() async {
        guard player?.isPlaying == true else { return }
        
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            audioPlayerDelegate.onFinish = {
                Task {
                    await audioPlayer.cancel()
                }
            }
        }
    }
    
    func cancel() {
        continuation?.resume()
        continuation = nil
    }
}

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onFinish: (() -> Void) = {}

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        logger.info("audioPlayerDidFinishPlaying: \(flag)")
        Task {
            await audioPlayer.cancel()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        logger.error("Audio player decode error: \(error?.localizedDescription ?? "unknown error")")
        Task {
            await audioPlayer.cancel()
        }
    }
}
