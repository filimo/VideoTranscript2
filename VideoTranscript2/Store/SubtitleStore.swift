
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

@MainActor class SubtitleStore: ObservableObject {
    let videoPlayer = VideoPlayerManager()

    @Storage("originalSubtitlesBookmark") private var originalSubtitlesBookmark: Data? = nil
    @Storage("translatedSubtitlesBookmark") private var translatedSubtitlesBookmark: Data? = nil

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
            logger.info("activeId didSet \(self.activeId)")
        }
    }

    @Published var isLoadingOriginal = false
    @Published var isLoadingTranslated = false

    @Published var timeObserverToken: Any? = nil

    private var stopPlayingTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    init() {
        videoPlayer.$currentTime
            .sink { [weak self] currentTime in
                self?.updateSubtitle(at: currentTime)
            }
            .store(in: &cancellables)
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

    func prevSubtitle() {
        if activeId > 0 {
            activeId -= 1
            if let subtitle = originalSubtitles.first(where: { $0.id == activeId }) {
                videoPlayer.seek(startTime: subtitle.startTime)
            }
        }
    }

    func nextSubtitle() {
        if activeId < originalSubtitles.count - 1 {
            activeId += 1
            if let subtitle = originalSubtitles.first(where: { $0.id == activeId }) {
                videoPlayer.seek(startTime: subtitle.startTime)
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

        videoPlayer.seek(startTime: startTime)
        videoPlayer.isPlaying = true

        stopPlayingTask = Task {
            await videoPlayer.stopPlaying(after: duration)
        }
    }
}

private extension SubtitleStore {
    func updateSubtitle(at currentTime: Double) {
        if let subtitle = originalSubtitles.first(where: {
            $0.startTime < $0.endTime ? $0.startTime ... $0.endTime ~= (currentTime + 0.2) : false
        }) {
            logger.info("Changed activeId(\(self.activeId)) \(currentTime) \(subtitle.id) \(subtitle.text)")
            if activeId != subtitle.id {
                activeId = subtitle.id
            }
        }
    }
}
