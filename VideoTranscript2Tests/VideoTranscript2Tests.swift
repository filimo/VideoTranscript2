//
//  VideoTranscript2Tests.swift
//  VideoTranscript2Tests
//
//  Created by Viktor Kushnerov on 16.07.23.
//

import AVKit
import Combine
@testable import VideoTranscript2
import XCTest

class VideoPlayerManagerTests: XCTestCase {
    var videoPlayerManager: VideoPlayerManager!
    var testURL: URL!

    @MainActor override func setUpWithError() throws {
        videoPlayerManager = VideoPlayerManager()
        testURL = URL(fileURLWithPath: "/Users/filimo/Downloads/ForWatch/WWDC/Swift concurrency/wwdc2022-110351_Eliminate data races using Swift Concurrency/wwdc2022-110351_hd.mp4")
    }

    override func tearDownWithError() throws {
        videoPlayerManager = nil
        testURL = nil
    }

    @MainActor func testSetPlayerWithValidURL() throws {
        videoPlayerManager.setPlayer(videoURL: testURL)
        XCTAssertEqual(videoPlayerManager.videoURL, testURL)
        XCTAssertNotNil(videoPlayerManager.player)
    }

    @MainActor func testPlayPause() throws {
        videoPlayerManager.setPlayer(videoURL: testURL)
        videoPlayerManager.play()
        XCTAssertTrue(videoPlayerManager.isPlaying)
        XCTAssertEqual(videoPlayerManager.player?.rate, Float(videoPlayerManager.playbackSpeed))

        videoPlayerManager.pause()
        XCTAssertFalse(videoPlayerManager.isPlaying)
        XCTAssertEqual(videoPlayerManager.player?.rate, 0)
    }

    @MainActor func testSeek() throws {
        videoPlayerManager.setPlayer(videoURL: testURL)
        videoPlayerManager.seek(startTime: 10)
        XCTAssertEqual(videoPlayerManager.player!.currentTime().seconds, 10.2, accuracy: 0.1)
    }

    @MainActor func testStopPlaying() async throws {
        videoPlayerManager.setPlayer(videoURL: testURL)
        videoPlayerManager.play()
        XCTAssertTrue(videoPlayerManager.isPlaying)

        await videoPlayerManager.stopPlaying(after: 2)
        XCTAssertFalse(videoPlayerManager.isPlaying)
    }

    @MainActor func testBookmarkHandling() throws {
        videoPlayerManager.videoURL = testURL
        XCTAssertEqual(videoPlayerManager.fetchURL(from: videoPlayerManager.videoURLBookmark), testURL)

        let invalidBookmarkData = Data([0x00, 0x01, 0x02])
        XCTAssertNil(videoPlayerManager.fetchURL(from: invalidBookmarkData))
    }

    @MainActor func testPlaybackSpeedChange() throws {
        videoPlayerManager.playbackSpeed = 1.5
        videoPlayerManager.setPlayer(videoURL: testURL)
        videoPlayerManager.play()
        XCTAssertEqual(videoPlayerManager.player?.rate, 1.5)
    }
}
