//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import SwiftUI
import AVKit
import UniformTypeIdentifiers

struct LoadVideoButton: View {
    @ObservedObject var viewModel: SubtitleViewModel

    var body: some View {
        Button("Load Video") {
            openFile(allowedContentTypes: [UTType.movie, .mp3]) { url in
                viewModel.videoURL = url                
            }
        }
    }
}
