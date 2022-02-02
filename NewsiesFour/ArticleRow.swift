//
//  ArticleRow.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/18/21.
//

import SwiftUI

struct ArticleRow: View {
    var article: Article
    var body: some View {
        HStack {
            Text(article.getTitle())
                .font(.title2)
            Spacer()
            VStack(alignment: .trailing){
                Text(article.getDateMMMMd())
                Text(article.getAuthor().getName())
                    .italic()
            }
            .fixedSize(horizontal: true, vertical: true)
            .font(.system(size: 12, weight: .light, design: .serif))
        }
        .padding()
    }
}

struct ArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        ArticleRow(article: Article(id: "17", title: "How to catch con artists", content: "catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can catch me if you can", date: 284012568000.0, author: Author(id: "142943", name: "Sanav Pai", articles: ["17", "14", "1298"], tag: "@sanavpai")))
    }
}
