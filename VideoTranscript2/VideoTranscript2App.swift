//
//  VideoTranscript2App.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 16.07.23.
//

import os
import SwiftUI

let appLogger = Logger()

let subsystem = Bundle.main.bundleIdentifier!
let subtitlesLogger = Logger(subsystem: subsystem, category: "Subtitles")
let videoLogger = Logger(subsystem: subsystem, category: "Video")
let audioLogger = Logger(subsystem: subsystem, category: "Audio")
let sleepLogger = Logger(subsystem: subsystem, category: "Sleep")
let keychainLogger = Logger(subsystem: subsystem, category: "Keychain")


@main
struct VideoTranscript2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(OpenAISpeechSynthesizerStore())
                .environmentObject(SubtitleStore())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    appLogger.error("\(Bundle.main.bundlePath)")
                }
        }
    }
}
