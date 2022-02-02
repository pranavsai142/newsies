//
//  RegisterView.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/14/21.
//

import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @EnvironmentObject var database: FireDatabaseReference
    @EnvironmentObject var dataConglomerate: DataConglomerate
    @State private var isRegistered = false
    @State private var failedToRegister = false
    @State private var unmatchedPasswords = false
    @State private var weakEmail = false
    @State private var weakPassword = false
    @State private var emailExists = false
    @State private var showingAlert = false
    @State private var networkError = false
    @State private var name = ""
    @State private var email = ""
    @State private var hometown = ""
    @State private var password = ""
    @State private var reenteredPassword = ""
    @State private var uid = ""
    
    var body: some View {
        VStack {
            Text("Create Account")
                .font(.title)
            TextField("perferred name", text: $name)
            TextField("email", text: $email)
            TextField("hometown", text: $hometown)
            SecureField("password", text: $password)
            SecureField("reenter password", text: $reenteredPassword)
            HStack {
                Spacer()
                if(unmatchedPasswords && !isRegistered) {
                    Text("Passwords do not match")
                } else if(emailExists) {
                  Text("Email already in use")
                } else if(weakEmail) {
                    Text("Weak email")
                } else if(weakPassword) {
                    Text("Weak password")
                } else if(networkError) {
                    Text("Network error")
                } else if(failedToRegister) {
                    Text("Error in registration")
                }
                Spacer()
            }
            Spacer()
            NavigationLink(
                destination: FeedView(uid: uid)
                    .environmentObject(database)
                    .environmentObject(dataConglomerate),
                isActive: $isRegistered) {
                Button(action: {
                    showingAlert = true
                }) {
                    Text("Register")
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("EULA"),
                      message: Text("Please review and accept the EULA to join the Newsies network at www.newsies.us/eula.html"),
                      primaryButton: .cancel(),
                      secondaryButton: .default(Text("Accept")) {
                        register()
                      })
            }
        }
        .padding()
    }
    private func register() {
        failedToRegister = false
        weakEmail = false
        weakPassword = false
        emailExists = false
        networkError = false
        if (password == reenteredPassword) {
            unmatchedPasswords = false
            Auth.auth().createUser(withEmail: email, password: password, completion: { (result, error) in
                if((result) != nil) {
//                    print("Registered")
                    isRegistered = true
                    failedToRegister = false
                    uid = result!.user.uid
//                    print(uid)
                    database.setValue(path: ["users", uid, "name"], value: name)
                    database.setValue(path: ["users", uid, "hometown"], value: hometown)
                    
//                    Clear text fields
                    name = ""
                    email = ""
                    hometown = ""
                    password = ""
                    reenteredPassword = ""
                }
                else {
                    print(error!)
                    let errorCode = (error as NSError?)!.code
                    if(errorCode == 17007) {
                        emailExists = true
                    } else if(errorCode == 17008) {
                        weakEmail = true
                    } else if(errorCode == 17026) {
                        weakPassword = true
                    } else if(errorCode == 17020) {
                        networkError = true
                    }
                    failedToRegister = true
                }
            })
        }
        else {
            unmatchedPasswords = true
            failedToRegister = true
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(FireDatabaseReference())
            .environmentObject(DataConglomerate())
    }
}
