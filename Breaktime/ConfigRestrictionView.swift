//
//  RestrictionView.swift
//  Breaktime
//
//  Created by Nathan Chan on 29/5/2025.
//

import SwiftUI
import UserNotifications
import ManagedSettings
import WidgetKit

struct ConfigRestrictionView: View {
    @ObservedObject var restrictionModel = MyRestrictionModel()
    @State private var showingRestrictionView = false
    @State private var scale = 0.1
    @State private var showFamilyPicker = false
    @AppStorage("endHour") private var endHour = 0
    @AppStorage("endMins") private var endMins = 0
    @AppStorage("inRestrictionMode") private var inRestrictionMode = false
    @EnvironmentObject var model: MyModel
    @State private var noAppsAlert = false
    @State private var maxAppsAlert = false
    
    //    @AppStorage("widgetEndHour", store: UserDefaults(suiteName:"group.ChristianPichardo.ScreenBreak")) private var widgetEndHour = 0
    //    @AppStorage("widgetEndMins", store: UserDefaults(suiteName:"group.ChristianPichardo.ScreenBreak")) private var widgetEndMins = 0
    //    @AppStorage("widgetInRestrictionMode", store: UserDefaults(suiteName:"group.ChristianPichardo.ScreenBreak")) private var widgetInRestrictionMode = false
    
    // Main View for Restrictions page
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor").edgesIgnoringSafeArea(.all)
                baseView
            }.onAppear(perform: {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
                
                if let customFont = UIFont(name: "OpenSans-SemiBold", size: 34) {
                    print("Hello")
                    UINavigationBar.appearance().largeTitleTextAttributes = [
                        .font: customFont,
                        .foregroundColor: UIColor.label
                    ]
                } else {
                    print("❌ Failed to load Inter-SemiBold")
                }
            })
        }
        .navigationViewStyle(.stack)
    }
    
    var baseView: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Restrictions")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                        
                        Spacer()
                        
                        Button(action: {
                            showFamilyPicker = true
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(Color("Subheading"), lineWidth: 1)
                                    .opacity(0.2)
                                    .frame(width: 36, height: 36)
                                Image(systemName: "slider.horizontal.3")
                                    .fontWeight(.light)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    if model.selectionToDiscourage.applicationTokens.isEmpty &&
                        model.selectionToDiscourage.categoryTokens.isEmpty {
                        Text("No apps selected.")
                            .foregroundColor(.gray)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else if !model.selectionToDiscourage.categoryTokens.isEmpty {
                        Text("Restricted Categories")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(Color("Subheading"))
                        
                        ForEach(Array(model.selectionToDiscourage.categoryTokens), id: \.self) { token in
                            Label(token)
                                .font(.system(size: 14))
                                .imageScale(.small)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    } else if !model.selectionToDiscourage.applicationTokens.isEmpty {
                        Text("Restricted Apps")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(Color("Subheading"))
                        
                        ForEach(Array(model.selectionToDiscourage.applicationTokens), id: \.self) { token in
                            Label(token)
                                .font(.system(size: 14))
                                .imageScale(.small)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.bottom, 80) // add padding so content is not hidden behind button
            }
            
            // Fixed button at bottom
            if !inRestrictionMode {
                Button(action: {
                    if MyModel.shared.selectionToDiscourage.applicationTokens.isEmpty &&
                        MyModel.shared.selectionToDiscourage.categoryTokens.isEmpty {
                        noAppsAlert = true
                        maxAppsAlert = false
                    } else if MyModel.shared.selectionToDiscourage.applicationTokens.count >= 20 {
                        noAppsAlert = false
                        maxAppsAlert = true
                    } else {
                        noAppsAlert = false
                        maxAppsAlert = false
                        for i in MyModel.shared.selectionToDiscourage.applications {
                            MyModel.shared.addApp(name: i.localizedDisplayName ?? "Temp")
                        }
                        UpdateRestriction.startNow()
                        inRestrictionMode = true
                    }
                }) {
                    Text("Start restricting")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .bold()
                        .background(Color("buttonColor"))
                        .foregroundColor(Color("buttonText"))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            } else {
                Button(action: {
                    inRestrictionMode = false
                    UpdateRestriction.endNow()
                }) {
                    Text("Take a Break")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .bold()
                        .background(Color("buttonColor"))
                        .foregroundColor(Color("buttonText"))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .padding()
        .sheet(isPresented: $showFamilyPicker) {
            FamilyPickerView(model: model, isDiscouragedPresented: $showFamilyPicker)
        }
    }
}

func formatTime(hours: Int, minutes: Int) -> String {
    var h = "\(hours)"
    var m = "\(minutes)"
    var pm = false
    if(hours % 12 > 0){
        h = "\(hours % 12)"
        pm = true
    }
    if(hours == 12){
        pm = true
    }
    if(minutes < 10){
        m = "0\(minutes)"
    }
    
    if(pm) {
        return "\(h):\(m) PM"
    } else {
        return "\(h):\(m) AM"
    }
}

class MyRestrictionModel: ObservableObject {
    @Published var inRestrictionMode = false
    @Published var startHour = 0
    @Published var startMin = 0
    @Published var endHour = 0
    @Published var endMins = 0
    @Published var startTime = ""
    @Published var endTime = ""
}

struct ConfigRestrictionView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigRestrictionView()
    }
}
