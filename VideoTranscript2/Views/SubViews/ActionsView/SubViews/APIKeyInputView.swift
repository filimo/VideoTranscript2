//
//  APIKeyInputView.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 14.06.24.
//

import SwiftUI

struct APIKeyInputView: View {
    @EnvironmentObject private var speechSynthesizer: OpenAISpeechSynthesizerStore

    var body: some View {
        TextField("OpenAI API Token", text: $speechSynthesizer.openAI_ApiToken)
            .font(.footnote)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .onChange(of: speechSynthesizer.openAI_ApiToken) { oldValue, newValue in
                if oldValue != "none" {
                    Task {
                        await speechSynthesizer.storeApiToken()
                    }
                }
            }
            .onAppear {
                Task {
                    await speechSynthesizer.restoreApiToken()
                }
            }
    }
}
