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
        NavigationStack {
            VStack {
                Image(systemName: "heart.fill")
                Text("Welcome to our little Health App")
                
                NavigationLink(destination: SecondView()) {
                    VStack {
                        Image(systemName: "scalemass.fill")
                        Text("Your weight")
                            .foregroundColor(.white)
                            .padding()
                            .cornerRadius(10)
                    }
                }
            }
            .onAppear {
                askForAutorization()
            }
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


