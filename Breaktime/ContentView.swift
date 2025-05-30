//
//  ContentView.swift
//  Breaktime
//
//  Created by Nathan Chan on 29/5/2025.
//

import SwiftUI


struct ContentView: View {
    @AppStorage("showOnboarding") var showOnboarding = true
    @AppStorage("firstTime") var firstTime = true
    var body: some View {
        VStack {
            ConfigRestrictionView()
        }
        .fullScreenCover(isPresented:$showOnboarding){
            OnboardingView()
        }
        .onAppear {
            if firstTime {
                showOnboarding = true
                firstTime = false
            } else {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                    launchScreenManager.dismiss()
//                }
            }
        }
        
    }
}

#Preview {
    ContentView()
}
