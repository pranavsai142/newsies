//
//  FeedView.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/14/21.
//

import SwiftUI
import Foundation


struct FeedView: View {
    @EnvironmentObject var database: FireDatabaseReference
    @EnvironmentObject var dataConglomerate: DataConglomerate
//    Tags that are the keys to accessing data from the database reference
    @State private var userNameTag = "user_name"
    @State private var userHometownTag = "user_hometown"
    @State private var userSubscriptionTag = "user_subscriptions"
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        df.setLocalizedDateFormatFromTemplate("MMMMd")
        return df
    }
    
    
    var uid : String
    
//    Define paths in the database
    var userPath: [String] {
        ["users", uid]
    }
    var userSubscriptionPath: [String] {
        ["users", uid, "subscriptions"]
    }
    
//    Run a query to pull values of user
    private var query: Bool {
        DispatchQueue.main.async {
            _ = database.getValue(path: userPath, key: "name", tag: userNameTag, dataConglomerate: dataConglomerate)
            _ = database.getValue(path: userPath, key: "hometown", tag: userHometownTag, dataConglomerate: dataConglomerate)
            _ = database.getValues(path: userSubscriptionPath, tag: userSubscriptionTag, dataConglomerate: dataConglomerate)
            _ = generateSubscriptions()
            _ = generateRecentArticles()
        }
        return true
    }
    
    
    var body: some View {
//        If the query did not fail or something.. right now query is usually always true
        if(query) {
//            Are the needed user values stored in the dictionary database nil? If not, load the view
            if(dataConglomerate.data[userNameTag] != nil && dataConglomerate.data[userHometownTag] != nil && dataConglomerate.data[userSubscriptionTag] != nil) {
//                Scroll View that Encapsulates everything in the feed. Maybe will need NavView as well
                NavigationView {
                    ScrollView {
                        HStack {
                            NavigationLink(destination: SearchView(uid: uid).environmentObject(database).environmentObject(dataConglomerate)) {
                                Text("search")
                            }
                                .frame(alignment: .leading)
                            Spacer()
                            Button(action: {
                                dataConglomerate.resetValues()
                            }) {
                                Text("refresh")
                            }
                                .frame(alignment: .center)
                            Spacer()
                            NavigationLink(destination: PublishView(uid: uid).environmentObject(database).environmentObject(dataConglomerate)) {
                                Text("publish")
                            }
                                .frame(alignment: .trailing)
                        }
                        HStack {
    //                        Display user's name
                            Text("Hello \(queryToString(tag: userNameTag))")
                            Spacer()
    //                        Display user's hometown
                            Text("Feed based in \(queryToString(tag: userHometownTag))")
                                .multilineTextAlignment(.trailing)
                        }
    //                    Iterate through subscriptions list. For each, display id and name horizontally
//                        if(dataConglomerate.subscriptions.count > 0) {
//                            ForEach(dataConglomerate.subscriptions) { subscription in
//                                HStack {
//                                    Text(subscription.getId())
//                                    Spacer()
//                                    Text(subscription.getName())
//                                    Spacer()
//                                    Text(subscription.getArticleUids()[0])
//                                }
//                            }
//                        }
//                        if(dataConglomerate.recentArticles.count > 0) {
//                            ForEach(dataConglomerate.recentArticles) { article in
//                                HStack {
//                                    Text(article.getId())
//                                    Spacer()
//                                    Text(article.getTitle())
//                                    Spacer()
//                                    Text(article.getDateMMMMd())
//                                }
//                            }
//                        }
                        if(dataConglomerate.recentArticles.count > 0) {
                            ForEach(dataConglomerate.getSortedRecentArticles()) { article in
                                NavigationLink(destination: ArticleView(uid: uid, article: article).environmentObject(database).environmentObject(dataConglomerate)) {
                                    ArticleRow(article: article)
                                }
                            }
                        } else {
                            Text("no recent articles")
                        }
                        NavigationLink(destination: SubscriptionView(uid: uid).environmentObject(database).environmentObject(dataConglomerate)) {
                            Text("view profile")
                        }
                            .padding()
                    }
                    .navigationBarHidden(true)
                    .padding()
                }
                .navigationBarHidden(true)
            }
        }
    }
    
//    Turn a query into a string
    private func queryToString(tag: String) -> String {
        return dataConglomerate.data[tag] as! String
    }
    
//    Turn a query of multiple things which also have a child in them into a string
//    In this case, the data from the daatabase comes as an array, and the first element is null
    private func childedListQueryToString(tag: String) -> String {
        let array = dataConglomerate.data[tag] as! NSArray
        var query = ""
        for item in array {
            if(array.index(of: item) > 0 && array.index(of: item) < (array.count - 1)) {
                query = query + (item as! String) + ", "
            }
            else if(array.index(of: item) == (array.count - 1)) {
                query = query + (item as! String)
            }
        }
        return query
    }
    //    Turn a query of multiple things with no child in them into a string
//    In this case, the data comed from the database as a Dictionary and the keys are the nessesary data
        private func listQueryToString(tag: String) -> String {
            let dict = dataConglomerate.data[tag] as! NSDictionary
            let queryString = (dict.allKeys as! [String]).joined(separator: ", ")
            return queryString
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
    //                            print("SUBID")
    //                            print(subscriptionName)
    //                            print("ARTICLES")
    //                            print(articles)
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
    
    private func generateRecentArticles() -> Bool {
//        If the subscriptions are loaded or there are atleast 1 subscription
        if (dataConglomerate.subscriptions.count > 0) {
            for subscription in dataConglomerate.subscriptions {
                let articlesUids = subscription.getArticleUids()
                var newestArticleUid = ""
                for articleUid in articlesUids {
                    let articlePath = ["articles", articleUid]
                    let dateTag = "article_" + articleUid + "_date"
                    if(database.getValue(path: articlePath, key: "date", tag: dateTag, dataConglomerate: dataConglomerate)) {
//                        print("hit", articleUid)
                        if(dataConglomerate.data[dateTag] != nil) {
//                            print("infofound", articleUid)
                            if(newestArticleUid == "") {
                                newestArticleUid = articleUid
                            } else {
                                let newestDateTag = "article_" + newestArticleUid + "_date"
                                let newestDate = dataConglomerate.data[newestDateTag] as! TimeInterval
                                let date = dataConglomerate.data[dateTag] as! TimeInterval
//                                print("comparing", articleUid)
//                                print("with", newestArticleUid)
//                                print("date", date)
//                                print("newest date", newestDate)
                                if(date > newestDate) {
                                    newestArticleUid = articleUid
                                }
                            }
                        }
                    }
                }
                if (newestArticleUid != "") {
                    let newestArticlePath = ["articles", newestArticleUid]
                    let newestContentTag = "article_" + newestArticleUid + "_content"
                    let newestTitleTag = "article_" + newestArticleUid + "_title"
                    let newestDateTag = "article_" + newestArticleUid + "_date"
                    if(database.getValue(path: newestArticlePath, key: "content", tag: newestContentTag, dataConglomerate: dataConglomerate) && database.getValue(path: newestArticlePath, key: "title", tag: newestTitleTag, dataConglomerate: dataConglomerate)) {
                        if(dataConglomerate.data[newestTitleTag] != nil && dataConglomerate.data[newestDateTag] != nil && dataConglomerate.data[newestContentTag] != nil) {
                            let newestTitle = dataConglomerate.data[newestTitleTag] as! String
                            let newestContent = dataConglomerate.data[newestContentTag] as! String
                            let newestDate = dataConglomerate.data[newestDateTag] as! TimeInterval
                            
                            let newestArticle = Article(id: newestArticleUid, title: newestTitle, content: newestContent, date: newestDate, author: subscription)
                            if(!dataConglomerate.recentArticles.contains(newestArticle)) {
                                dataConglomerate.recentArticles.append(newestArticle)
                            }
                        }
                    }
                }
            }
        }
        return true
    }
    
//    private func generateRecentArticles() -> [Article] {
//        userSubs = generateSubscriptions()
//        for subscription in userSubs {
//            <#code#>
//        }
//    }
}


struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(uid: "yca5i8BSWaMRW8ci11Xe8SKB7Cj2")
            .environmentObject(FireDatabaseReference())
            .environmentObject(DataConglomerate())
    }
}
