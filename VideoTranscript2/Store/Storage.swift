
//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import SwiftUI

@propertyWrapper
struct Storage<T: Codable>: DynamicProperty {
    private let key: String
    private let store: UserDefaults = .standard
    private let defaultValue: T

    var wrappedValue: T {
        get {
            guard let data = store.object(forKey: key) as? Data else {
                return defaultValue
            }
            return (try? JSONDecoder().decode(T.self, from: data)) ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            store.set(data, forKey: key)
        }
    }

    init(wrappedValue defaultValue: T, _ key: String) {
        self.key = key
        self.defaultValue = defaultValue
    }
}

