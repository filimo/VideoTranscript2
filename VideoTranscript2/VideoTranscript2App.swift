//
//  VideoTranscript2App.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 16.07.23.
//

import SwiftUI

@main
struct VideoTranscript2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(OpenAISpeechSynthesizerStore())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear{
                    print(Bundle.main.bundlePath)
                }
        }
    }
}
