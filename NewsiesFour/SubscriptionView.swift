//
//  SubscriptionView.swift
//  Newsies
//
//  Created by Pranav Sai on 11/7/21.
// Hi
//

import SwiftUI

struct SubscriptionView: View {
    var uid : String
    @EnvironmentObject var database: FireDatabaseReference
    @EnvironmentObject var dataConglomerate : DataConglomerate
    @State private var userNameTag = "user_name"
    @State private var userHometownTag = "user_hometown"
    @State private var userSubscriptionTag = "user_subscriptions"
    @State private var userAuthorTag = "user_author"
    
//    Define paths in the database
    var userPath: [String] {
        ["users", uid]
    }
    var userSubscriptionPath: [String] {
        ["users", uid, "subscriptions"]
    }
    
    var body: some View {
        if(query) {
            ScrollView {
                if(dataConglomerate.data[userNameTag] != nil && dataConglomerate.data[userHometownTag] != nil) {
                    Text("Your Profile")
                        .bold()
                    HStack {
                        Text("Name: \(queryToString(tag: userNameTag))")
                        Spacer()
                    }
                    HStack {
                        Text("Hometown: \(queryToString(tag: userHometownTag))")
                        Spacer()
                    }
                    if(dataConglomerate.data[userAuthorTag] != nil) {
                        NavigationLink(
                            destination: AuthorView(author: queryToAuthor(tag: userAuthorTag), uid: uid)
                                .environmentObject(database)
                                .environmentObject(dataConglomerate)) {
                            AuthorRow(author: queryToAuthor(tag: userAuthorTag))
                        }
                    } else {
                        Text("User has not published articles")
                    }
                }
                Divider()
                Text("Your Subscriptions")
                    .bold()
                if(dataConglomerate.subscriptions.count > 0) {
                    ForEach(dataConglomerate.getSortedSubscriptions()) { subscription in
                    NavigationLink(
                        destination: AuthorView(author: subscription, uid: uid)
                            .environmentObject(database).environmentObject(dataConglomerate)) {
                        AuthorRow(author: subscription)
                        }
                    }
                } else {
                    Text("no subscriptions")
                }
            }
            .padding()
            .navigationBarTitle("User Data", displayMode: .inline)
        }
//        if(query) {
//            Text("helo")
//        }
    }
    
    private func queryToString(tag: String) -> String {
        return dataConglomerate.data[tag] as! String
    }
    
    private func queryToAuthor(tag: String) -> Author {
        return dataConglomerate.data[tag] as! Author
    }
    
    private var query: Bool {
        let userAuthorNameTag = "subscription_" + uid + "_name"
        let userTagTag = "subscription_" + uid + "_tag"
        let userArticlesTag = "subscription_" + uid + "_articles"
        DispatchQueue.main.async {
            _ = database.getValue(path: userPath, key: "name", tag: userNameTag, dataConglomerate: dataConglomerate)
            _ = database.getValue(path: userPath, key: "hometown", tag: userHometownTag, dataConglomerate: dataConglomerate)
            _ = database.getValues(path: userSubscriptionPath, tag: userSubscriptionTag, dataConglomerate: dataConglomerate)
            _ = database.getValue(path: ["authors", uid], key: "name",tag: userAuthorNameTag, dataConglomerate: dataConglomerate)
            _ = database.getValue(path: ["authors", uid], key: "tag",tag: userTagTag, dataConglomerate: dataConglomerate)
            _ = database.getList(path: ["authors", uid, "articles"], tag: userArticlesTag, dataConglomerate: dataConglomerate)
            _ = generateUserAuthor()
            _ = generateSubscriptions()
        }
        return true
//        let val = (database.getValue(path: userPath, key: "name", tag: userNameTag, dataConglomerate: dataConglomerate) && database.getValue(path: userPath, key: "hometown", tag: userHometownTag, dataConglomerate: dataConglomerate) && database.getValues(path: userSubscriptionPath, tag: userSubscriptionTag, dataConglomerate: dataConglomerate) && database.getValue(path: ["authors", uid], key: "name",tag: userAuthorNameTag, dataConglomerate: dataConglomerate) && database.getValue(path: ["authors", uid], key: "tag",tag: userTagTag, dataConglomerate: dataConglomerate) && database.getList(path: ["authors", uid, "articles"], tag: userArticlesTag, dataConglomerate: dataConglomerate) && generateUserAuthor() && generateSubscriptions())
    }
    
    private func generateUserAuthor() -> Bool {
        let userAuthorNameTag = "subscription_" + uid + "_name"
        let userTagTag = "subscription_" + uid + "_tag"
        let userArticlesTag = "subscription_" + uid + "_articles"
        if (dataConglomerate.data[userAuthorNameTag] != nil && dataConglomerate.data[userTagTag] != nil && dataConglomerate.data[userArticlesTag] != nil) {
            let userAuthorName = dataConglomerate.data[userAuthorNameTag] as! String
            let userTag = dataConglomerate.data[userTagTag] as! String
            if(dataConglomerate.data[userArticlesTag] is NSDictionary) {
                let articleDict = dataConglomerate.data[userArticlesTag] as! NSDictionary
                let userArticles = articleDict.allKeys as! [String]
//                            print("SUBID")
//                            print(subscriptionName)
//                            print("ARTICLES")
//                            print(articles)
                dataConglomerate.data[userAuthorTag] = Author(id: uid, name: userAuthorName, articles: userArticles, tag: userTag)
                return true
//                            print("DATACONGLOMERATE")
//                            print(dataConglomerate.subscriptions)
            } else if(userTag != "DNE") {
                dataConglomerate.data[userAuthorTag] = Author(id: uid, name: userAuthorName, articles: [], tag: userTag)
            }
        }
        return false
    }

//    A helper function to create Subscription objects based on all the user's subscriptions
    private func generateSubscriptions() -> Bool{
//        Array of user's subscription's uids
        if dataConglomerate.data[userSubscriptionTag] != nil {
            let array = dataConglomerate.data[userSubscriptionTag] as! NSArray
            for item in array {
//            First element of array is null so this if statement is required
//                user id
                let id = (item as! String)
//                Define tags to act as keys to access data in the database
                let nameTag = "subscription_" + id + "_name"
                let tagTag = "subscription_" + id + "_tag"
                let articlesTag = "subscription_" + id + "_articles"
//                Subscription init variables
                var subscriptionName = ""
                var subscriptionTag = ""
                var articles = [String]()
//                Query the bitch. THIS HAS TO BE CHANGED IF TREE IS RENAMED TO
//                    authors INSTEAD OF subscriptions
                if(database.getValue(path: ["authors", id], key: "name",tag: nameTag, dataConglomerate: dataConglomerate) && database.getValue(path: ["authors", id], key: "tag",tag: tagTag, dataConglomerate: dataConglomerate) && database.getList(path: ["authors", id, "articles"], tag: articlesTag, dataConglomerate: dataConglomerate)) {
//                    If the data is not nil, proceed to try and read it
                    if (dataConglomerate.data[nameTag] != nil && dataConglomerate.data[tagTag] != nil && dataConglomerate.data[articlesTag] != nil) {
//                        Get subscription name
                        subscriptionName = dataConglomerate.data[nameTag] as! String
                        subscriptionTag = dataConglomerate.data[tagTag] as! String
//                        Get articles
                        if(dataConglomerate.data[articlesTag] is NSDictionary) {
                            let articleDict = dataConglomerate.data[articlesTag] as! NSDictionary
                            articles = articleDict.allKeys as! [String]
                        }
    //                            print("SUBID")
    //                            print(subscriptionName)
    //                            print("ARTICLES")
    //                            print(articles)
                        if(subscriptionTag != "DNE") {
                            let sub = Author(id: id, name: subscriptionName, articles: articles, tag: subscriptionTag)
    //                            print("DATACONGLOMERATE")
    //                            print(dataConglomerate.subscriptions)
                            if(!dataConglomerate.subscriptions.contains(sub)) {
                                dataConglomerate.subscriptions.append(sub)
                            }
                        }
                    }
                }
            }
            return true
        }
        else {
            return false
        }
    }
}
struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView(uid: "12312313")
            .environmentObject(FireDatabaseReference())
            .environmentObject(DataConglomerate())
    }
}

    
