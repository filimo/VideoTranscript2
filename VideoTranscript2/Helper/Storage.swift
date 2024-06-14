
//
//  Storage.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import Combine
import SwiftUI

@propertyWrapper
struct Storage<T: Codable>: DynamicProperty {
    private let key: String
    private let store: UserDefaults
    private let defaultValue: T
    private let subject: CurrentValueSubject<T, Never>

    var wrappedValue: T {
        get {
            guard let data = store.object(forKey: key) as? Data else {
                return defaultValue
            }
            let value = (try? JSONDecoder().decode(T.self, from: data)) ?? defaultValue
            subject.value = value
            return value
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            store.set(data, forKey: key)
            subject.value = newValue
        }
    }

    var projectedValue: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }

    init(wrappedValue defaultValue: T, _ key: String, store: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store
        subject = CurrentValueSubject<T, Never>(defaultValue)

        if let data = store.object(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(T.self, from: data)
        {
            subject.value = value
        }
    }
}
