//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import AVKit
import SwiftUI
import UniformTypeIdentifiers

struct LoadVideoButton: View {
    @EnvironmentObject private var subtitleStore: SubtitleStore
    
    @AppStorage("lastVideoURL") var lastVideoURL: URL?

    var body: some View {
        Button("Load Video") {
            Task {
                if let url = await FileHelper.openFile(allowedContentTypes: [UTType.movie, .mp3]) {
                    subtitleStore.videoURL = url
                    lastVideoURL = url
                }
            }
        }

        GroupBox {
            Text("SRT")

            Toggle("in 2 colums", isOn: $subtitleStore.showTwoSubtitlesColumns)
                .toggleStyle(.button)

            GroupBox {
                Text("Load")

                Button("Original") {
                    Task {
                        if let url = await FileHelper.openFile(allowedContentTypes: [UTType.STR]) {
                            subtitleStore.originalSubtitles = try await SubtitleHelper.loadSRT(from: url)
                        } else {
                            print("User cancelled file opening")
                        }
                    }
                }

                Button("Translated") {
                    Task {
                        if let url = await FileHelper.openFile(allowedContentTypes: [UTType.STR]) {
                            subtitleStore.translatedSubtitles = try await SubtitleHelper.loadSRT(from: url)
                        } else {
                            print("User cancelled file opening")
                        }
                    }
                }
            }
        }
        .navigationTitle("VideoTranscript2 - \(lastVideoURL?.path ?? "")")
    }
}
