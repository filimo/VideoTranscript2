//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import AVKit
import SwiftUI
import UniformTypeIdentifiers

struct SubtitlesView: View {
    @ObservedObject var viewModel: SubtitleViewModel
    @Binding var subtitles: [Subtitle]
    var title: String

    var body: some View {
        ScrollViewReader { scrollProxy in
            VStack {
                List(subtitles) { subtitle in
                    Text(subtitle.text)
                        .font(.body)
                        .id(subtitle.id)
                        .underline(subtitle.id == viewModel.activeId)
                        .onTapGesture {
                            // Seek the player to the start time of the subtitle
                            viewModel.seek(startTime: subtitle.startTime)
                            viewModel.activeId = subtitle.id
                        }
                }
                Button("Load \(title) SRT") {
                    openFile(allowedContentTypes: [UTType(filenameExtension: "srt")!]) { url in
                        Task {
                            do {
                                let newSubtitles = try await loadSRT(from: url)
                                subtitles = newSubtitles
                            } catch {
                                print("Failed to load SRT: \(error)")
                            }
                        }
                    }
                }
            }
            .onReceive(viewModel.debounceActiveId) { id in
                print("onReceive debounceActiveId", id)
                scrollProxy.scrollTo(id - 5, anchor: .top)
            }
        }
    }
}
