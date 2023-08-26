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
    @ObservedObject var viewModel: SubtitleViewModel

    var body: some View {
        Button("Load Video") {
            Task {
                if let url = await openFile(allowedContentTypes: [UTType.movie, .mp3]) {
                    viewModel.videoURL = url
                }
            }
        }

        Toggle("SRT in 2 colums", isOn: $viewModel.showTwoSubtitlesColumns)
            .toggleStyle(.button)

        HStack {
            Text("Load SRT: ")

            Button("Original") {
                Task {
                    if let url = await openFile(allowedContentTypes: [UTType.STR]) {
                        viewModel.originalSubtitles = try await loadSRT(from: url)
                    } else {
                        print("User cancelled file opening")
                    }
                }
            }

            Button("Translated") {
                Task {
                    if let url = await openFile(allowedContentTypes: [UTType.STR]) {
                        viewModel.translatedSubtitles = try await loadSRT(from: url)
                    } else {
                        print("User cancelled file opening")
                    }
                }
            }
        }
        .padding(5) // Добавление отступов вокруг группы
        .background(Color.gray.opacity(0.1)) // Добавление фона для выделения группы
        .cornerRadius(8) // Скругление углов для эстетического вида
        .onAppear {
            viewModel.updateSubtitles2()
        }
    }
}
