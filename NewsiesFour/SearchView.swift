//
//  SearchView.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/18/21.
//

import SwiftUI

struct SearchView: View {
    var uid : String
    @EnvironmentObject var database: FireDatabaseReference
    @EnvironmentObject var dataConglomerate : DataConglomerate
    @State private var authorTagSearch = ""
    @State private var searchComplete = false
    @State private var failedToSearch = false
    var body: some View {
        if (generateAuthors()) {
            VStack {
                TextField("@tag", text: $authorTagSearch)
                Button(action: {
                    search()
                }) {
                    Text("search")
                }
                if(dataConglomerate.foundAuthors.count > 0) {
                    ForEach(dataConglomerate.foundAuthors) { foundAuthor in
                    NavigationLink(
                        destination: AuthorView(author: foundAuthor, uid: uid)
                            .environmentObject(database).environmentObject(dataConglomerate)) {
                        AuthorRow(author: foundAuthor)
                        }
                    }
                } else if(failedToSearch) {
                    Text("incorrect tag")
                        .padding()
                } else if(searchComplete) {
                    Text("no results")
                        .padding()
                }
                Spacer()
            }
            .padding()
        }
    }
        
    private func search() -> Void {
        dataConglomerate.resetQuery()
        dataConglomerate.resetSearch()
        searchComplete = false
        failedToSearch = false
        authorTagSearch = authorTagSearch.lowercased()
        if(authorTagSearch.hasPrefix("@")) {
            let queryFoundTag = "query_" + authorTagSearch + "_found"
            let queryTag = "query_" + authorTagSearch + "_tag"
            if(database.queryDatabaseForString(path: ["authors"], child: "tag", query: authorTagSearch, foundTag: queryFoundTag, tag: queryTag, dataConglomerate: dataConglomerate)) {
                searchComplete = true
            }
            else {
                searchComplete = false
            }
        } else {
            failedToSearch = true
        }
    }
    
    private func generateAuthors() -> Bool {
        if(!failedToSearch) {
            let queryFoundTag = "query_" + authorTagSearch + "_found"
            let queryTag = "query_" + authorTagSearch + "_tag"
            DispatchQueue.main.async {
                let resultFound = dataConglomerate.query[queryFoundTag]
                if(resultFound != nil) {
                    if (resultFound as! Bool) {
//                        print("FOUND")
                        let authorData = dataConglomerate.query[queryTag]
                        var authorDictionary : NSDictionary
                        var authorUID = ""
                        //Conditional to handle firebase quirk. If author is the first entry it is represented as an NSArray, if it is
                        //any other entry other than the first it is an NSdictionary.
                        //seems hard to pull uuid from author entry if it is the first one. Going to hardcode in the first author
                        //in the database so this isint a problem.
                        if authorData is NSArray {
                            let authorArray = authorData as! NSArray
                            authorUID = authorArray[0] as! String
//                            print("uUIdUUID", authorUID)
                            authorDictionary = authorArray[1] as! NSDictionary
                        }
                        //remove nested dictionary
                        else if authorData is NSDictionary {
                            authorDictionary = authorData as! NSDictionary
                            authorUID = authorDictionary.allKeys[0] as! String
                            authorDictionary = authorDictionary.value(forKey: authorUID) as! NSDictionary
                        }
                        else {
                            authorDictionary = NSDictionary()
                        }
                        var publishedArticles = [String]();
                        if(authorDictionary["articles"] is NSDictionary) {
                            publishedArticles = (authorDictionary["articles"] as! NSDictionary).allKeys as! [String]
                        }
    //                        print(publishedArticles)
                        let authorName = authorDictionary["name"] as! String
                        let authorTag = authorDictionary["tag"] as! String
//                        print("uUIdUUID", authorTag)
                        let foundAuthor = Author(id: authorUID, name: authorName, articles: publishedArticles, tag: authorTag)
                        if(!dataConglomerate.foundAuthors.contains(foundAuthor)) {
//                            print("mmade it")
                            dataConglomerate.foundAuthors.append(foundAuthor)
                        }
                    }
                }
            }
        }
        return true
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(uid: "yca5i8BSWaMRW8ci11Xe8SKB7Cj2")
    }
}
