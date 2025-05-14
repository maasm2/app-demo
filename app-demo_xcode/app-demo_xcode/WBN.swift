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
    @State var stepCount: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "heart.fill")
                Text("Welcome to our little Health App")
                Text("Steps today: \(stepCount)")
                    .font(.headline)
                NavigationLink(destination: SecondView()) {
                    VStack {
                        Text("Your weight")
                        Image(systemName: "scalemass.fill")
                    }
                }
            }
            .onAppear {
                askForAutorization()
            }
        }
    }
    
    func askForAutorization() {
        if !HKHealthStore.isHealthDataAvailable() {
            print("HealthKit isn't available on this device")
            return
        }
        
        // Define the types we want to access
        guard let wgt = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            print("Unable to access health data types")
            return
        }
        
        // Request authorization for BOTH weight and steps
        let readTypes: Set = [wgt, stepType]
        let writeTypes: Set = [wgt]
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            if success {
                print("Authorization granted")
                self.fetchStepCount() // Fetch steps after authorization
            } else {
                print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func fetchStepCount() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch step count: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            
            DispatchQueue.main.async {
                self.stepCount = steps
            }
        }
        
        healthStore.execute(query)
    }
}
#Preview {
    ContentView()
}


