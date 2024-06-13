//
//  AudioPlayerActorTests.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 13.06.24.
//

import AVFoundation
@testable import VideoTranscript2
import XCTest

class AudioPlayerActorTests: XCTestCase {
    var testURL: URL!
    var testURL1: URL!
    var testURL2: URL!

    override func setUpWithError() throws {
        testURL = URL(fileURLWithPath: "/Users/filimo/Library/Containers/by.filimo.VideoTranscript2/Data/Library/Caches/697b8b471920de3e849a9e34445dbc5a0dee462631afc132639c524b55d92162.mp3")
        testURL1 = URL(fileURLWithPath: "/Users/filimo/Library/Containers/by.filimo.VideoTranscript2/Data/Library/Caches/5b61a080bf56024c2bd3cdb9b8482411282e40dfb70ec0e0f6fee6ddac6d7d7c.mp3")
        testURL2 = URL(fileURLWithPath: "/Users/filimo/Library/Containers/by.filimo.VideoTranscript2/Data/Library/Caches/981e8b601e34e81449f7a3bab5fe816585cf9f2072c493cdafb80eea75ca1143.mp3")
    }

    override func tearDownWithError() throws {
        testURL = nil
        testURL1 = nil
        testURL2 = nil
    }

    func testPlayAudio() async throws {
        await audioPlayer.playAudio(url: testURL)
        let isPlaying = await audioPlayer.isPlaying()
        XCTAssertTrue(isPlaying)
    }

    func testPlay() async throws {
        await audioPlayer.playAudio(url: testURL)
        await audioPlayer.pause()
        await audioPlayer.play()
        let isPlaying = await audioPlayer.isPlaying()
        XCTAssertTrue(isPlaying)
    }

    func testStop() async throws {
        await audioPlayer.playAudio(url: testURL)
        await audioPlayer.stop()
        let isPlaying = await audioPlayer.isPlaying()
        XCTAssertFalse(isPlaying)
    }

    func testPause() async throws {
        await audioPlayer.playAudio(url: testURL)
        await audioPlayer.pause()
        let isPlaying = await audioPlayer.isPlaying()
        XCTAssertFalse(isPlaying)
    }

    func testReplay() async throws {
        await audioPlayer.playAudio(url: testURL)
        await audioPlayer.replay()
        let isPlaying = await audioPlayer.isPlaying()
        let currentTime = await audioPlayer.currentTime()
        XCTAssertTrue(isPlaying)
        XCTAssertEqual(currentTime, 0, accuracy: 0.1)
    }

    func testWaitForAudioToFinishPlaying() async throws {
        await audioPlayer.playAudio(url: testURL)
        await audioPlayer.waitForAudioToFinishPlaying()
        let isPlaying = await audioPlayer.isPlaying()
        XCTAssertFalse(isPlaying)
    }

    func testPlaySequentialAudioFiles() async throws {
        await audioPlayer.playAudio(url: testURL1)
        var isPlaying = await audioPlayer.isPlaying()
        XCTAssertTrue(isPlaying, "Первый аудиофайл должен воспроизводиться")

        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)

        await audioPlayer.stop()
        isPlaying = await audioPlayer.isPlaying()
        XCTAssertFalse(isPlaying, "Первый аудиофайл должен остановить")

        await audioPlayer.playAudio(url: testURL2)
        isPlaying = await audioPlayer.isPlaying()
        XCTAssertTrue(isPlaying, "Второй аудиофайл должен воспроизводиться")

        try await Task.sleep(nanoseconds: 4 * 1_000_000_000)
        isPlaying = await audioPlayer.isPlaying()
        XCTAssertTrue(isPlaying, "Второй аудиофайл должен воспроизводиться")
    }
}
