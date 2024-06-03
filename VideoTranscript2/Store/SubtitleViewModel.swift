
//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import AVKit
import Combine
import Foundation

class SubtitleViewModel: ObservableObject {
    @Published var playbackSpeed: Float = 1.0
    
    @Storage("originalSubtitles") var originalSubtitles: [Subtitle] = [] {
        willSet {
            updateSubtitles2()
            objectWillChange.send()
        }
    }

    @Storage("translatedSubtitles") var translatedSubtitles: [Subtitle] = [] {
        willSet {
            updateSubtitles2()
            objectWillChange.send()
        }
    }

    @Storage("showTwoSubtitlesColumns") var showTwoSubtitlesColumns = true {
        willSet {
            objectWillChange.send()
        }
    }

    var subtitles2: [Subtitle] = []

    @Published var activeId: Int = 0 {
        didSet {
            print("activeId didSet", activeId)
            debounceActiveIdSubject.send(activeId)
        }
    }

    private var debounceActiveIdSubject = PassthroughSubject<Int, Never>()
    var debounceActiveId: some Publisher<Int, Never> {
        debounceActiveIdSubject
//            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    @Published var isLoadingOriginal = false
    @Published var isLoadingTranslated = false

    @Storage("videoURLBookmark") private var videoURLBookmark: Data? = nil
    var videoURL: URL? {
        get {
            guard let bookmarkData = videoURLBookmark else { return nil }
            var isStale = false
            let url = try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
            if isStale {
                // Handle stale bookmark here
                print("The bookmark is stale.")
                videoURLBookmark = nil
            }

            return url
        }
        set {
            if let url = newValue {
                do {
                    setPlayer(videoURL: url)
                    let bookmarkData = try url.bookmarkData()
                    videoURLBookmark = bookmarkData
                } catch {
                    print("Failed to create bookmark for \(url): \(error)")
                    videoURLBookmark = nil
                }
            } else {
                videoURLBookmark = nil
            }
        }
    }

    @Published var player: AVPlayer? = nil
    @Published var timeObserverToken: Any? = nil
    @Published var isPlaying = false {
        didSet {
            print("isPlaying", isPlaying)
            if isPlaying {
                player?.play()
                player?.rate = playbackSpeed
            } else {
                player?.pause()
            }
        }
    }

    @Storage("currentTime") var currentTime: Double = 0
}

extension SubtitleViewModel {
    func updateSubtitles2() {
        subtitles2 = originalSubtitles.map { item in
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
            
            let interval = CMTime(value: 1, timescale: 2) // every tenth of a second, say
            if let player {
                timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { _ in
                    let currentTime = CMTimeGetSeconds(player.currentTime())
                    self.currentTime = currentTime
                    if let subtitle = self.originalSubtitles.first(where: {
                        if $0.startTime < $0.endTime {
                            return $0.startTime ... $0.endTime ~= currentTime
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
        player?.seek(to: CMTime(seconds: Double(startTime + 0.1), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
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

        seek(startTime: startTime)
        isPlaying = true

        // Set a timer to stop the player after the subtitle has finished
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isPlaying = false
        }
    }
}
