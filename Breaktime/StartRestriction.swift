//
//  StartRestriction.swift
//  Breaktime
//
//  Created by Nathan Chan on 31/5/2025.
//

import Foundation
import DeviceActivity
import UserNotifications

// The Device Activity name is how I can reference the activity from within my extension
extension DeviceActivityName {
    // Set the name of the activity to "daily"
    static let daily = Self("daily")
}

extension DeviceActivityEvent.Name {
    // Set the name of the event to "discouraged"
    static let discouraged = Self("discouraged")
}


class StartRestriction {
    static public func startNow() {
        print("Starting restriction immediately...")

        let notifCenter = UNUserNotificationCenter.current()

        // Schedule a notification for now + 2 minutes (optional)
        let now = Date()
        let triggerDate = Calendar.current.date(byAdding: .minute, value: 2, to: now)!

        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)

        let startTrigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let startContent = UNMutableNotificationContent()
        startContent.title = "Screen Break"
        startContent.body = "You've entered Restriction Mode! Good Luck!"
        startContent.sound = UNNotificationSound.default

        let startRequest = UNNotificationRequest(identifier: UUID().uuidString, content: startContent, trigger: startTrigger)
        notifCenter.add(startRequest)

        // Define daily repeating schedule from midnight to 23:59 every day
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        let center = DeviceActivityCenter()
        do {
            try center.startMonitoring(.daily, during: schedule)
            print("Monitoring started immediately")
        } catch {
            print("Error starting monitoring: ", error)
        }

        MyModel.shared.setShieldRestrictions()
    }
}
//
//    static public func setSchedule(endHour: Int, endMins:Int) {
//        print("Setting schedule...")
//        print(("Hour is: ", Calendar.current.dateComponents([.hour, .minute], from: Date()).hour!))
//        
//        let year = Calendar.current.dateComponents([.year], from: Date()).year ?? 1
//        let month = Calendar.current.dateComponents([.month], from: Date()).month ?? 1
//        let day = Calendar.current.dateComponents([.day], from: Date()).day ?? 1
//        let dateComp = Calendar.current.dateComponents([.hour], from: Date())
//        let hourComponents = Calendar.current.dateComponents([.ehour], from: Date())
//        let curHour = hourComponents.hour ?? 0
//        let minuteComponents = Calendar.current.dateComponents([.minute], from: Date())
//        let curMins = minuteComponents.minute ?? 0
//        
//        
//        var nextMin = curMins + 2
//        
//        let notifCenter = UNUserNotificationCenter.current()
//        
//        let startTrigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(year: year, month: month, day: day, hour: curHour, minute: nextMin), repeats: false)
//        let startContent = UNMutableNotificationContent()
//        startContent.title = "Screen Break"
//        startContent.body = "You've entered Restriction Mode! Good Luck!"
//        startContent.categoryIdentifier = "customIdentifier"
//        startContent.userInfo = ["customData": "fizzbuzz"]
//        startContent.sound = UNNotificationSound.default
//        let startRequest = UNNotificationRequest(identifier: UUID().uuidString, content: startContent, trigger: startTrigger)
//        notifCenter.add(startRequest)
//        
//        
//        //Setting Notifications
//        
//        // Will try this out later
//        /*let center = UNUserNotificationCenter.current()
//        let halfTrigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: endHour, minute: endMins), repeats: true)
//        let halfContent = UNMutableNotificationContent()
//        halfContent.title = "Screen Break - Restriction Mode"
//        halfContent.body = "You're halfway done with Restriction Mode. You've got this!"
//        halfContent.categoryIdentifier = "customIdentifier"
//        halfContent.userInfo = ["customData": "fizzbuzz"]
//        halfContent.sound = UNNotificationSound.default
//        let halfRequest = UNNotificationRequest(identifier: UUID().uuidString, content: halfContent, trigger: halfTrigger)
//        notifCenter.add(halfRequest)*/
//        
//        let endTrigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(year: year, month: month, day: day, hour: endHour, minute: endMins), repeats: false)
//        let endContent = UNMutableNotificationContent()
//        endContent.title = "Screen Break"
//        endContent.body = "Congrats! You've reached the end of Restriction Mode"
//        endContent.categoryIdentifier = "customIdentifier"
//        endContent.userInfo = ["customData": "fizzbuzz"]
//        endContent.sound = UNNotificationSound.default
//        let endRequest = UNNotificationRequest(identifier: UUID().uuidString, content: endContent, trigger: endTrigger)
//        notifCenter.add(endRequest)
//        
//        print("END TIME: \(endHour):\(endMins)")
//        
//        MyModel.shared.setShieldRestrictions()
//        
//        
//        let schedule = DeviceActivitySchedule(
//            // I've set my schedule to start and end at midnight
//            // perhaps change this
//            intervalStart: .init(hour: 0, minute: 0),
//            intervalEnd: .init(hour: 23, minute: 59),
//            repeats: true
//        )
//
//
//        
////        // Threshold doesnt really matter for right now?
////        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
////            .discouraged: DeviceActivityEvent(
////                applications: MyModel.shared.selectionToDiscourage.applicationTokens,
////                threshold: DateComponents(second: 15)
////            )
////        ]
//        
//        // Create a Device Activity center
//        let center = DeviceActivityCenter()
//        do {
//            print("Try to start monitoring...")
//            // Call startMonitoring with the activity name, schedule, and events
//            try center.startMonitoring(.daily, during: schedule)
//        } catch {
//            print("Error monitoring schedule: ", error)
//        }
//    }
//}
// Another ingredient to shielding apps is figuring out what the guardian wants to discourage
// The Family Controls framework has a SwiftUI element for this: the family activity picker
