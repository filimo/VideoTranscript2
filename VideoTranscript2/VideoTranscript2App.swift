//
//  VideoTranscript2App.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 16.07.23.
//

import SwiftUI
import os

let logger = Logger()

@main
struct VideoTranscript2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(OpenAISpeechSynthesizerStore())
                .environmentObject(SubtitleStore())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear{
                    logger.error("\(Bundle.main.bundlePath)")
                }
        }
    }
}
