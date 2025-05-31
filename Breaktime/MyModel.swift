//
//  MyModel.swift
//  Breaktime
//
//  Created by Nathan Chan on 29/5/2025.
//

import Foundation
import FamilyControls
import ManagedSettings
import CoreData

private let _MyModel = MyModel()

class MyModel: ObservableObject {
    // Import ManagedSettings to get access to the application shield restriction
    let store = ManagedSettingsStore()
    let container: NSPersistentContainer
    //@EnvironmentObject var store: ManagedSettingsStore
    
    @Published var selectionToDiscourage: FamilyActivitySelection
    @Published var selectionToEncourage: FamilyActivitySelection
    @Published var savedSelection: [AppEntity] = []
    
    init() {
        container = NSPersistentContainer(name:"ApplicationsContainer")
        container.loadPersistentStores{(description, error) in
            if let error = error{
                print("ERROR LOADING CORE DATA. \(error)")
            }else{
                print("Successfully loaded core data.")
            }
            
        }
        selectionToDiscourage = FamilyActivitySelection()
        selectionToEncourage = FamilyActivitySelection()
        fetchApps()
    }
    
    func fetchApps(){
        let request = NSFetchRequest<AppEntity>(entityName: "AppEntity")
        do{
            savedSelection = try container.viewContext.fetch(request)
            print("Fetched apps from Core Data:")
            for app in savedSelection {
                print("- \(app.name ?? "Unknown")")
            }
        }catch let error{
            print("Error fetching. \(error)")
        }
    }
    
    func addApp(name: String){
        print("Adding app with name: \(name)")  // Debug print
        let newApp = AppEntity(context: container.viewContext)
        newApp.name = name
        savedSelection.append(newApp)  // Add the new app immediately to update UI
        saveData()
    }
    
    func deleteAllApps(){
        for entity in savedSelection{
            container.viewContext.delete(entity)
        }
        saveData()
    }
    
    func saveData() {
        do{
            try container.viewContext.save()
            fetchApps()
        } catch let error{
            print("Error saving. \(error)")
        }
    }
    
    
    class var shared: MyModel {
        return _MyModel
    }
    
    func setShieldRestrictions() {
        // Pull the selection out of the app's model and configure the application shield restriction accordingly
        print("Setting restriction")
        let applications = MyModel.shared.selectionToDiscourage
        
//        for token in applications.applicationTokens {
//            print("App token: \(token)")
//            if let app = store.application(for: token),
//               let name = app.localizedDisplayName {
//                addApp(name: name)
//            } else {
//                print("Could not resolve app for token.")
//            }
//        }
//
//        for categoryToken in applications.categoryTokens {
//            print("Category token: \(categoryToken)")
//            let categoryName = categoryToken.rawValue.capitalized
//            addApp(name: "Category: \(categoryName)")
//        }
        
//        for token in applications.applicationTokens {
//            print("App token: \(token)")
//        }
//        for token in applications.categoryTokens {
//            print("Category token: \(token)")
//        }
        store.shield.applications = applications.applicationTokens.isEmpty ? nil : applications.applicationTokens
        store.shield.applicationCategories = applications.categoryTokens.isEmpty
        ? nil
        : ShieldSettings.ActivityCategoryPolicy.specific(applications.categoryTokens)
    }
}
