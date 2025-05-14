//
//  ContentView.swift
//  app-demo_xcode
//
//  Created by Aya Mankari on 2025-05-12.
//

import SwiftUI
import HealthKit

let healthStore = HKHealthStore()

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "heart.fill")
            Text("Welcome to our little Health App")
        }
        .onAppear {
            askForAutorization()
        }
    }
    
    
}
    
    func askForAutorization(){
        if(!HKHealthStore.isHealthDataAvailable()){
            print("HealthKit isn't available on this device")
            return
        }
        
        guard let wgt = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            print("The user didn't allow access to this data")
            return
        }
        
        guard let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            print("Step Count is not available")
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(Date())
        let endDate = Date()
        
        let stepsToday = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        
        
        let everyDay = DateComponents(day: 1)
        
        let sumOfStepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: stepsToday,
            options: .cumulativeSum,
            anchorDate: endDate,
            intervalComponents: everyDay)
       
        let updateQueue = sumOfStepsQuery.results(for: store)
        
        updateTask = Task {
            for try await results in updateQueue {
                results.statistics()
                
            }
        }
        
        
        let readTypesWGT: Set = [wgt]
        let writeTypesWGT: Set = [wgt]
        
        healthStore.requestAuthorization(toShare: writeTypesWGT, read: readTypesWGT) { (success, error) in
           
            let readStatus = healthStore.authorizationStatus(for: wgt)
            
            if readStatus == .sharingAuthorized {
                print("We have access to the weight data yeaaaaaah")
            } else {
                print("We don't have access: User denied")
            }
        }
    }


#Preview {
    ContentView()
}


