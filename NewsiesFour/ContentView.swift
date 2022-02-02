//
//  ContentView.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/14/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var database: FireDatabaseReference
    @EnvironmentObject var dataConglomerate: DataConglomerate
    var body: some View {
        LoginView()
            .environmentObject(database)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FireDatabaseReference())
            .environmentObject(DataConglomerate())
    }
}
