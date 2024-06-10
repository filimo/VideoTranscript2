//
//  NavigationButtons.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 22.07.23.
//

import SwiftUI

struct ContentView: View {
    @State var isPresented = true

    var body: some View {
        PlayerWithSubtitlesView()
            .inspector(isPresented: $isPresented) {
                ActionsView()
                    .inspectorColumnWidth(min: 150, ideal: 225, max: 400)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isPresented.toggle()
                    }) {
                        Image(systemName: isPresented ? "eye.slash" : "eye")
                    }
                }
            }
    }
}
