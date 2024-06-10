
//
//  SubtitleStore.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import AVKit
import Combine
import Foundation
import SwiftUI

class SubtitleStore: ObservableObject {
    @AppStorage("playbackSpeed") var playbackSpeed: Double = 1.0

    @Storage("videoURLBookmark") private var videoURLBookmark: Data? = nil
    @Storage("originalSubtitlesBookmark") private var originalSubtitlesBookmark: Data? = nil
    @Storage("translatedSubtitlesBookmark") private var translatedSubtitlesBookmark: Data? = nil

    var videoURL: URL? {
        get {
            return fetchURL(from: videoURLBookmark)
        }
        set {
            videoURLBookmark = storeURL(newValue)
        }
    }

    @Storage("originalSubtitles") var originalSubtitles: [Subtitle] = [] {
        willSet {
            objectWillChange.send()
        }
    }

    @Storage("translatedSubtitles") var translatedSubtitles: [Subtitle] = [] {
        willSet {
            objectWillChange.send()
        }
    }

    @Storage("showTwoSubtitlesColumns") var showTwoSubtitlesColumns = true {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var activeId: Int = 0 {
        didSet {
            print("activeId didSet", activeId)
            debounceActiveIdSubject.send(activeId)
        }
    }

    @Published var isLoadingOriginal = false
    @Published var isLoadingTranslated = false

    @Published var player: AVPlayer? = nil
    @Published var timeObserverToken: Any? = nil

    @Published var isPlaying = false

    @Storage("currentTime") var currentTime: Double = 0

    private var stopPlayingTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    private var debounceActiveIdSubject = PassthroughSubject<Int, Never>()

    init() {
        $isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                self?.handleIsPlayingChange(isPlaying)
            }
            .store(in: &cancellables)
    }
}

extension SubtitleStore {
    var debounceActiveId: some Publisher<Int, Never> {
        debounceActiveIdSubject
//            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

extension SubtitleStore {
    var subtitles2: [Subtitle] {
        return originalSubtitles.map { item in
            if let text = translatedSubtitles.first(where: { $0.id == item.id })?.text {
                return Subtitle(
                    id: item.id,
                    startTime: item.startTime,
                    endTime: item.endTime,
                    text: item.text + "\n    \(text)"
                )
            }

            return item
        }
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

            let interval = CMTime(value: 1, timescale: 2) // every tenth of a second, say
            if let player {
                timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { _ in
                    let currentTime = CMTimeGetSeconds(player.currentTime())
                    self.currentTime = currentTime
                    if let subtitle = self.originalSubtitles.first(where: {
                        if $0.startTime < $0.endTime {
                            return $0.startTime ... $0.endTime ~= (currentTime + 0.2)
                        } else {
                            return false
                        }
                    }) {
                        if self.activeId != subtitle.id {
                            print("Changed activeId", currentTime, subtitle)
                            self.activeId = subtitle.id
                        }
                    }
                }

                // Seek to the saved currentTime value
                player.seek(to: CMTime(seconds: currentTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            }
        }
    }

    func seek(startTime: TimeInterval) {
        print("seek", startTime)

        let additionalTime = 0.2
        let startTimeInSeconds = Double(startTime) + additionalTime
        let time = CMTime(seconds: startTimeInSeconds, preferredTimescale: 600)

        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func prevSubtitle() {
        if activeId > 0 {
            activeId -= 1
            if let subtitle = originalSubtitles.first(where: { $0.id == activeId }) {
                seek(startTime: subtitle.startTime)
            }
        }
    }

    func nextSubtitle() {
        if activeId < originalSubtitles.count - 1 {
            activeId += 1
            if let subtitle = originalSubtitles.first(where: { $0.id == activeId }) {
                seek(startTime: subtitle.startTime)
            }
        }
    }

    func getCurrentOriginalSubtitle() -> String {
        originalSubtitles.first(where: { $0.id == activeId })?.text ?? ""
    }

    func getCurrentTranlatatedSubtitle() -> String {
        translatedSubtitles.first(where: { $0.id == activeId })?.text ?? ""
    }

    func nextSubtitleAndPlay() {
        nextSubtitle()
        repeatSubtitle()
    }

    func repeatSubtitle() {
        guard let subtitle = originalSubtitles.first(where: { $0.id == activeId }) else { return }

        // Seek to the start time of the subtitle and start playing
        let startTime = subtitle.startTime - 0.4
        // Calculate the duration of the subtitle
        let duration = subtitle.endTime - startTime

        stopPlayingTask?.cancel()

        seek(startTime: startTime)
        isPlaying = true

        stopPlayingTask = Task {
            await stopPlaying(after: duration)
        }
    }
}

private extension SubtitleStore {
    private func fetchURL(from bookmark: Data?) -> URL? {
        guard let bookmarkData = bookmark else { return nil }
        var isStale = false
        let url = try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
        if isStale {
            print("The bookmark is stale.")
            return nil
        }
        return url
    }

    private func storeURL(_ url: URL?) -> Data? {
        guard let url = url else { return nil }
        do {
            setPlayer(videoURL: url)
            return try url.bookmarkData()
        } catch {
            print("Failed to create bookmark for \(url): \(error)")
            return nil
        }
    }
}

private extension SubtitleStore {
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
        print("isPlaying", isPlaying)

        if isPlaying {
            playIfPaused()
        } else {
            pauseIfPlaying()
        }
    }

    func playIfPaused() {
        guard let player = player else { return }
        if player.rate == 0 {
            player.play()
            player.rate = Float(playbackSpeed)
        }
    }

    func pauseIfPlaying() {
        guard let player = player else { return }
        if player.rate > 0 {
            player.pause()
        }
    }
}
