//
//  ContentView.swift
//  Breaktime
//
//  Created by Nathan Chan on 29/5/2025.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        VStack {
            RestrictionView()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
