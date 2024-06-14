//
//  SleepPreventer.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 11.06.24.
//

import AVKit
import Combine
import IOKit.pwr_mgt
import SwiftUI

@Observable
class AVPlayerObserver {
    var isPlaying = false
    private var assertionID: IOPMAssertionID = 0
    private let reasonForActivity = "Playing video" as CFString
    private var cancellables = Set<AnyCancellable>()

    func observe(player: AVPlayer) {
        player.publisher(for: \.rate)
            .sink { [weak self] rate in
                if rate == 0 {
                    self?.isPlaying = false
                    self?.allowSleep()
                } else {
                    self?.isPlaying = true
                    self?.preventSleep()
                }
            }
            .store(in: &cancellables)
    }

    private func preventSleep() {
        let success = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString,
                                                  IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                  reasonForActivity,
                                                  &assertionID)
        if success == kIOReturnSuccess {
            sleepLogger.info("Successfully prevented sleep")
        } else {
            sleepLogger.error("Failed to prevent sleep")
        }
    }

    func allowSleep() {
        let success = IOPMAssertionRelease(assertionID)
        if success == kIOReturnSuccess {
            sleepLogger.info("Successfully allowed sleep")
        } else {
            sleepLogger.error("Failed to allow sleep")
        }
    }
}
