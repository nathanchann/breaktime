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
                
                // Check current time to see if user was in restrictions mode
               checkForRestrictionMode()
                
            }).onDisappear(perform: {
                // Check current time to see if user was in restriction mode
                checkForRestrictionMode()
            })
            .navigationTitle("Breaktime").bold()
        }
        .navigationViewStyle(.stack)
    }
    
    // Create view that will render when there are no current restrictions
    var baseView: some View{
        VStack(alignment: .center) {
            HStack {
                Text("Restricted Apps")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(Color("Subheading"))
                Spacer()  // pushes the button to the right
                
                Button(action: {
                    showFamilyPicker = true
                }) {
                    ZStack {
                        Circle()
                            .stroke(Color("Subheading"), lineWidth: 1) // Gray border with no fill
                            .opacity(0.2)
                            .frame(width: 36, height: 36)       // Adjust size as needed
                        Image(systemName: "slider.horizontal.3")
                            .fontWeight(.light)
                            .foregroundColor(.black)
                    }
                }
                
                .sheet(isPresented: $showFamilyPicker) {
                    FamilyPickerView(model: model, isDiscouragedPresented: $showFamilyPicker)
                }
            }
            .padding(.bottom, 8)  // optional spacing below the header
            Spacer()
            if !inRestrictionMode {
                Button(action: {
                    if MyModel.shared.selectionToDiscourage.applicationTokens.count == 0 &&
                        MyModel.shared.selectionToDiscourage.categoryTokens.count == 0 {
                        noAppsAlert = true
                        maxAppsAlert = false
                    } else if MyModel.shared.selectionToDiscourage.applicationTokens.count >= 20 {
                        noAppsAlert = false
                        maxAppsAlert = true
                    } else {
                        noAppsAlert = false
                        maxAppsAlert = false
                        print("APPS SELECTED : \(MyModel.shared.selectionToDiscourage.applications.count)")
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
            } else {
                Button(action: {
                    // Logic to "take a break", i.e. end restriction mode
                    inRestrictionMode = false
                    UpdateRestriction.endNow()
                    // Optionally stop monitoring device activity if needed
                    // Maybe call DeviceActivityCenter().stopMonitoring(...)
                    print("Restriction ended, taking a break")
                }) {
                    Text("Take a Break")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .bold()
                        .background(Color("buttonColor"))
                        .foregroundColor(Color("buttonText"))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }
    
    // Update Restriction Mode
    func checkForRestrictionMode() -> Void {
//        let hourComponents = Calendar.current.dateComponents([.hour], from: Date())
//        let curHour = hourComponents.hour ?? 0
//        
//        let minuteComponents = Calendar.current.dateComponents([.minute], from: Date())
//        let curMins = minuteComponents.minute ?? 0

//        if(curHour > endHour){
//            widgetInRestrictionMode = false
//            inRestrictionMode = false
//            MyModel.shared.deleteAllApps()
//            WidgetCenter.shared.reloadAllTimelines()
//        } else if(curHour == endHour && curMins >= endMins){
//            widgetInRestrictionMode = false
//            inRestrictionMode = false
//            MyModel.shared.deleteAllApps()
//            WidgetCenter.shared.reloadAllTimelines()
//        }
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
