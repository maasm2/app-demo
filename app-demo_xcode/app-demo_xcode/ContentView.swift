//
//  ContentView.swift
//  app-demo_xcode
//
//  Created by Aya Mankari on 2025-05-12.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "heart.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Welcome to our little application!")
                .foregroundColor(.blue)
            Text("")
        }
        .padding()
    }
}


#Preview {
    ContentView()
}


