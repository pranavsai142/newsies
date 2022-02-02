//
//  AuthorRow.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 9/13/21.
//

import SwiftUI

struct AuthorRow: View {
    var author: Author
    var body: some View {
        HStack {
            Text(author.getName())
            Spacer()
            Text(author.getTag())
        }
        .padding()
    }
}

struct AuthorRow_Previews: PreviewProvider {
    static var previews: some View {
        AuthorRow(author: Author(id: "142943", name: "Sanav Pai", articles: ["17", "14", "1298"], tag: "@sanavpai"))
    }
}
