//
//  String.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 8.06.24.
//

import Foundation
import CryptoKit

extension String {
    func sha256() -> String {
        let data = Data(utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            [UInt8](SHA256.hash(data: bytes))
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
