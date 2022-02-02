//
//  NewsiesFourApp.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/14/21.
//

import SwiftUI
import Firebase

@main
struct NewsiesFourApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(FireDatabaseReference())
                .environmentObject(DataConglomerate())
        }
    }
}
