//
//  ArticleView.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/18/21.
//

import SwiftUI

struct ArticleView: View {
    var uid: String
    var article: Article
    @EnvironmentObject var database: FireDatabaseReference
    @EnvironmentObject var dataConglomerate: DataConglomerate
    @State private var showingAlert = false
    @State private var flagged = false
    var body: some View {
        ScrollView {
            if(articleBelongsToUser()) {
                HStack {
                    Spacer()
                    NavigationLink(
                        destination: EditView(uid: uid, article: article)
                            .environmentObject(database)
                            .environmentObject(dataConglomerate)) {
                        Text("edit")
                    }
//                    Button(action: {
//                        showingAlert = true
//                    }, label: {
//                            Text("delete")
//                    })
//                    .alert(isPresented: $showingAlert) {
//                        Alert(title: Text("Warning!"),
//                              message: Text("Are you sure you want to DELETE this article?"),
//                              primaryButton: .cancel(),
//                              secondaryButton: .destructive(Text("Yes, DELETE this article.")) {
//                                deleteArticle()
//                              })
//                    }
                }
            }
            HStack {
                Text(article.title)
                    .font(.title)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                VStack(alignment: .trailing) {
                    Text(article.getAuthor().getName())
                        .italic()
                    Text(article.getAuthor().getTag())
                }
                .font(.system(size: 14, weight: .light, design: .serif))
            }
            Divider()
            Text(article.getContent())
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Spacer()
                Button(action: {
                    toggleFlagArticle()
                }, label: {
                    if(flagged) {
                        Image(systemName: "flag.fill")
                    } else {
                        Image(systemName: "flag")
                    }
                })
                    .padding()
            }
        }
        .padding()
        .navigationBarTitle(article.title, displayMode: .inline)
    }
    
    private func articleBelongsToUser() -> Bool {
        return (article.getAuthor().getId() == uid)
    }
    
    private func toggleFlagArticle() {
        if(!flagged) {
            database.setValue(path: ["flagged", article.getId()], value: true)
            flagged = true
        } else {
            database.setValue(path: ["flagged", article.getId()], value: false)
            flagged = false
        }
    }
    
    private func deleteArticle() {
//        Remove from articles list
        database.removeValue(path: ["articles", article.getId()])
//        Remove link to article from author
        database.removeValue(path: ["authors", article.getAuthor().getId(), "articles", article.getId()])
    }
}

struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleView(uid: "fdfdsfd", article: Article(id: "17", title: "How to catch con artists", content: "catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can", date: 284012568000.0, author: Author(id: "142943", name: "Sanav Pai", articles: ["17", "14", "1298"], tag: "@sanavpai")))
    }
}
