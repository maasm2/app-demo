//
//  SecondeView.swift
//  app-demo_xcode
//
//  Created by Aya Mankari on 2025-05-14.
//
import SwiftUI
import HealthKit

struct SecondView: View {
    @State private var weightInput: String = ""
    @State private var message: String = ""
    @State private var currentWeight: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Current weight")
            Text(currentWeight)
            Text("Your weight")
                .font(.title)

            Text("Enter your weight in kg:")
                .font(.subheadline)

            TextField("Weight in kg", text: $weightInput)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Enter") {
                if let weight = Double(weightInput) {
                    message = "Weight entered: \(weight) kg"
                    print("Weight entered: \(weight)")
                    
                    let weightQuantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: weight)
                    let now = Date()
                    guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
                        print("Could not get the weight quantity type:(")
                        return
                    }
                    let weightSample = HKQuantitySample(
                        type: weightType,
                        quantity: weightQuantity,
                        start: now,
                        end: now
                    )
                    
                    healthStore.save(weightSample) { success, error in
                        if success {
                            print("Weight \(weight) kg saved to HealthKit!!!! yeeeeayyy")
                        } else {
                            print("Error saving weight:(")
                        }
                    }
                } else {
                    message = "Please enter a valid weight!! "
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Text(message)
                .foregroundColor(.gray)
        }
        .padding()
        .onAppear {
            fetchLatestWeight { weight in
                if let w = weight {
                    currentWeight = String(format: "%.1f kg", w)
                } else {
                    currentWeight = "Unavailable"
                }
            }
        }
    }
}

func fetchLatestWeight(completion: @escaping (Double?) -> Void) {
    guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
        completion(nil)
        return
    }

    let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
    let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortByDate]) { _, results, _ in
        guard let sample = results?.first as? HKQuantitySample else {
            completion(nil)
            return
        }

        let kg = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
        completion(kg)
    }

    healthStore.execute(query)
}
