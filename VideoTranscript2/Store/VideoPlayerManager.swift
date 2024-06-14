//
//  VideoPlayerManager.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 12.06.24.
//

import AVKit
import Combine
import Foundation
import SwiftUI

@MainActor
class VideoPlayerManager: ObservableObject {
    @AppStorage("playbackRate") var playbackRate: Double = 1.0 {
        didSet {
            player?.rate = Float(playbackRate)
        }
    }

    @Storage("currentTime") var currentTime: Double = 0
    @Storage("videoURLBookmark") private(set) var videoURLBookmark: Data? = nil

    @Published var isPlaying = false

    var videoURL: URL? {
        get {
            return fetchURL(from: videoURLBookmark)
        }
        set {
            videoURLBookmark = storeURL(newValue)
        }
    }

    private(set) var player: AVPlayer?

    private var timeObserverToken: Any?
    private var cancellables = Set<AnyCancellable>()

    init() {
        $isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                self?.handleIsPlayingChange(isPlaying)
            }
            .store(in: &cancellables)
    }

    func setPlayer(videoURL: URL?) {
        if let urlAsset = player?.currentItem?.asset as? AVURLAsset {
            let url = urlAsset.url
            if videoURL == url { return }
        }

        if let videoURL {
            // Remove the old time observer
            if let player = player, let timeObserverToken = timeObserverToken {
                player.removeTimeObserver(timeObserverToken)
            }

            player = AVPlayer(url: videoURL)
            player?.volume = 0.05

            let interval = CMTime(value: 1, timescale: 2) // every tenth of a second
            if let player {
                timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { _ in
                    Task { @MainActor in
                        self.currentTime = CMTimeGetSeconds(player.currentTime())
                    }
                }
                seekToSavedCurrentTime()
            }
        }
    }

    func seekToSavedCurrentTime() {
        seek(startTime: currentTime)
    }

    func seek(startTime: TimeInterval) {
        logger.info("\(startTime)")

        let additionalTime = 0.2
        let startTimeInSeconds = Double(startTime) + additionalTime
        let time = CMTime(seconds: startTimeInSeconds, preferredTimescale: 600)

        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func play() {
        guard let player = player else { return }
        if player.rate == 0 {
            player.play()
            player.rate = Float(playbackRate)
            isPlaying = true
        }
    }

    func pause() {
        guard let player = player else { return }
        if player.rate > 0 {
            player.pause()
            isPlaying = false
        }
    }

    func stopPlaying(after duration: TimeInterval) async {
        // Set a delay to stop the player after the subtitle has finished
        do {
            try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000)) // duration в секундах, конвертируем в наносекунды
            if !Task.isCancelled {
                isPlaying = false
            }
        } catch {
            // Обработка ошибки, если задача была отменена
        }
    }

    func handleIsPlayingChange(_ isPlaying: Bool) {
        logger.info("isPlaying \(isPlaying)")

        if isPlaying {
            play()
        } else {
            pause()
        }
    }
}

extension VideoPlayerManager {
    func fetchURL(from bookmark: Data?) -> URL? {
        guard let bookmarkData = bookmark else { return nil }
        var isStale = false
        let url = try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
        if isStale {
            logger.info("The bookmark is stale.")
            return nil
        }
        return url
    }

    func storeURL(_ url: URL?) -> Data? {
        guard let url = url else { return nil }
        do {
            setPlayer(videoURL: url)
            return try url.bookmarkData()
        } catch {
            logger.error("Failed to create bookmark for \(url): \(error)")
            return nil
        }
    }
}
