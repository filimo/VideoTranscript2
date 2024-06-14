//
//  VideoTranscript2App.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 16.07.23.
//

import os
import SwiftUI

let logger = Logger()

actor TestActor {
    let test = ""

    private func cancel() {
        logger.info("\(String(describing: self.test))")
    }
}

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
                    logger.error("\(Bundle.main.bundlePath)")
                }
        }
    }
}
