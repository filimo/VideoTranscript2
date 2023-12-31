//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import AVKit
import SwiftUI

struct SubtitlesView: View {
    @ObservedObject var viewModel: SubtitleViewModel
    @Binding var subtitles: [Subtitle]
    var title: String
    @State private var lastUpdate = Date()

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
                .id(lastUpdate)
                Button("Load \(title) SRT") {
                    Task {
                        if let url = await openFile(allowedContentTypes: [UTType.STR]) {
                            subtitles = try await loadSRT(from: url)
                            lastUpdate = Date()
                        } else {
                            print("User cancelled file opening")
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
