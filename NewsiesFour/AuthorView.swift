//
//  AuthorView.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/18/21.
//

import SwiftUI

struct AuthorView: View {
    var author: Author
    var uid : String
    @EnvironmentObject var database : FireDatabaseReference
    @EnvironmentObject var dataConglomerate : DataConglomerate
    @State private var notSubscribed = false
    @State private var isSorted = false
    @State private var initialized = false
    @State private var userSubscriptionTag = "user_subscriptions"
    
    private var userSubscriptionPath: [String] {
        ["users", uid, "subscriptions"]
    }
    var body: some View {
        if (loadArticles()) {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(author.getName())
                        Text(author.getTag())
                    }
                    Spacer()
//                    Subscribe star button. Golden star if already subscribed, star outline if not subscribed.
//                    Toggle switch that updates the database when sub or unsub
                    Button(action: {
                        toggleSub()
                    }, label: {
                        if(isSubscribed()) {
                            Text("unsubscribe")
                        } else {
                            Text("subscribe")
                        }
                    })
                }
                .padding()
                if (dataConglomerate.authorArticles.count > 0) {
                    ScrollView {
                        ForEach(dataConglomerate.getSortedAuthorArticles()) { article in
                            NavigationLink(destination: ArticleView(uid: uid, article: article).environmentObject(database).environmentObject(dataConglomerate)) {
                                ArticleRow(article: article)
                            }
                        }
                    }
                } else {
                    Text("no published articles")
                    Spacer()
                }
            }
        }
    }
    
//    private func sortArticles() -> Bool {
//        if(!isSorted) {
//            DispatchQueue.main.async {
//                dataConglomerate.authorArticles.sort(by: >)
//                isSorted = true
//            }
//        }
//        return true
//    }
    
    private func toggleSub() {
        if isSubscribed() {
            database.removeValue(path: ["users", uid, "subscriptions", author.getId()])
            dataConglomerate.resetSubscriptions()
        } else if (notSubscribed) {
            database.setValue(path: ["users", uid, "subscriptions", author.getId()], value: true)
            dataConglomerate.resetSubscriptions()
        }
    }
    
    private func isSubscribed() -> Bool {
        if(database.getValues(path:  userSubscriptionPath, tag: userSubscriptionTag, dataConglomerate: dataConglomerate)) {
            return checkForSub()
        }
        return false
    }
    
//    A helper function to create Subscription objects based on all the user's subscriptions
    private func checkForSub() -> Bool{
//        Array of user's subscription's uids
        if dataConglomerate.data[userSubscriptionTag] != nil {
            let array = dataConglomerate.data[userSubscriptionTag] as! NSArray
            for item in array {
//            First element of array is null so this if statement is required
//                user id
                let id = (item as! String)
//                print("id", id)
                if (id == author.getId()) {
//                    print("IS SUBBED")
                    return true
                }
            }
            DispatchQueue.main.async {
                notSubscribed = true
            }
        }
        return false
    }
    private func loadArticles() -> Bool {
//        Resets Author's articles from previous searches if the view is being loaded initially
        if(!initialized) {
//            print("VIEW INIT")
            DispatchQueue.main.async {
                dataConglomerate.resetAuthorView()
                initialized = true
            }
        }
        let articlesUids = author.getArticleUids()
        for articleUid in articlesUids {
            let articlePath = ["articles", articleUid]
            let dateTag = "article_" + articleUid + "_date"
            if(database.getValue(path: articlePath, key: "date", tag: dateTag, dataConglomerate: dataConglomerate)) {
//                        print("hit", articleUid)
                if(dataConglomerate.data[dateTag] != nil) {
                    let contentTag = "article_" + articleUid + "_content"
                    let titleTag = "article_" + articleUid + "_title"
                    let dateTag = "article_" + articleUid + "_date"
                    if(database.getValue(path: articlePath, key: "content", tag: contentTag, dataConglomerate: dataConglomerate) && database.getValue(path: articlePath, key: "title", tag: titleTag, dataConglomerate: dataConglomerate)) {
                        if(dataConglomerate.data[titleTag] != nil && dataConglomerate.data[dateTag] != nil && dataConglomerate.data[contentTag] != nil) {
                            let title = dataConglomerate.data[titleTag] as! String
                            let content = dataConglomerate.data[contentTag] as! String
                            let date = dataConglomerate.data[dateTag] as! TimeInterval
                            let article = Article(id: articleUid, title: title, content: content, date: date, author: author)
//                            dataConglomerate.authorArticles.append(article)
                            if(!dataConglomerate.authorArticles.contains(article)) {
                                dataConglomerate.authorArticles.append(article)
                            }
                        }
                    }
                }
            }
        }
        return true
    }
}
struct AuthorView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorView(author: Author(id: "142943", name: "Sanav Pai", articles: ["17", "14", "1298"], tag: "@sanavpai"), uid: "yca5i8BSWaMRW8ci11Xe8SKB7Cj2")
    }
}
