//
//  BreaktimeApp.swift
//  Breaktime
//
//  Created by Nathan Chan on 29/5/2025.
//

import SwiftUI
import ManagedSettings
import FamilyControls

@main
struct BreaktimeApp: App {
    let center = AuthorizationCenter.shared
    @StateObject var store = ManagedSettingsStore()
    @StateObject var model = MyModel.shared
    @State private var isAuthorized = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isAuthorized {
                    ContentView().environmentObject(model)
                        .environmentObject(store)
                } else {
                    ProgressView("Requesting Permission...")
                        .task {
                            do {
                                try await center.requestAuthorization(for: .individual)
                                isAuthorized = true
                            } catch {
                                print("Authorization failed: \(error.localizedDescription)")
                                // Handle authorization failure if needed
                            }
                        }
                }
            }
        }
    }
}
