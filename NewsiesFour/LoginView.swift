//
//  LoginView.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/14/21.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var database: FireDatabaseReference
    @EnvironmentObject var dataConglomerate: DataConglomerate
    @State private var isAuthenticated = false
    @State private var tryAgainLater = false
    @State private var networkError = false
    @State private var failed = false
    @State private var email = ""
    @State private var password = ""
//    uid is a string
    @State private var uid = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("email", text: $email)
                SecureField("password", text: $password)
                NavigationLink(
                    destination: FeedView(uid: uid)
                        .environmentObject(database)
                        .environmentObject(dataConglomerate),
                    isActive: $isAuthenticated) {
                    Button(action: {
                        authenticate()
                    }) {
                        Text("Login")
                    }
                }
                    .navigationBarTitle(Text("Newsies"), displayMode: .automatic)
                
                if(tryAgainLater) {
                    Text("Reset passowrd or try again later")
                } else if(networkError) {
                    Text("Network error")
                } else if(failed) {
                    Text("Incorrect credentials")
                }
                Spacer()
                VStack {
                    NavigationLink(
                        destination: ResetView()
                            .environmentObject(database)
                            .environmentObject(dataConglomerate)) {
                            Text("Reset Password")
                    }
                        .padding()
                    NavigationLink(
                        destination: RegisterView()
                            .environmentObject(database)
                            .environmentObject(dataConglomerate)) {
                            Text("Register")
                    }
                }
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
    
    private func authenticate() {
        failed = false
        networkError = false
        tryAgainLater = false
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if((result) != nil) {
//                print("success!")
                isAuthenticated = true
                failed = false
                print(result!.user.uid)
                uid = result!.user.uid
            }
            else {
                isAuthenticated = false
                failed = true
//                print("ERROR")
                print(error!)
                let errorCode = (error as NSError?)!.code
                if(errorCode == 17010) {
                    tryAgainLater = true
                } else if(errorCode == 17020) {
                    networkError = true
                }
                isAuthenticated = false
                failed = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(FireDatabaseReference())
            .environmentObject(DataConglomerate())
    }
}
