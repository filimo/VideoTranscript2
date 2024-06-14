//
//  FileHelper.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 8.06.24.
//

import AppKit
import Foundation
import UniformTypeIdentifiers

@MainActor
struct FileHelper {
    static func openFile(allowedContentTypes: [UTType]) async -> URL? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = allowedContentTypes
        let result = await panel.begin()
        if result == .OK, let url = panel.url {
            return url
        } else {
            return nil
        }
    }
}
