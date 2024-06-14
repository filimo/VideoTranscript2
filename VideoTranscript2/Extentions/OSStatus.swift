//
//  OsStatus.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 14.06.24.
//
import Security

extension OSStatus {
    func getOSStatusString() -> String {
        return SecCopyErrorMessageString(self, nil) as String? ?? "nil"
    }
}
