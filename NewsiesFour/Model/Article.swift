//
//  Article.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/16/21.
//

import Foundation

struct Article: Identifiable, Equatable, Comparable {
    
    static func < (lhs: Article, rhs: Article) -> Bool {
        return (lhs.date <= rhs.date)
    }
    
    static func > (lhs: Article, rhs: Article) -> Bool {
        return (lhs.date > rhs.date)
    }
    
    var id: String
    var title: String
    var content: String
    var date: TimeInterval
    var author: Author
    private var dateFormatter = DateFormatter()
    init(id: String, title: String, content: String, date: TimeInterval, author: Author) {
        dateFormatter.locale = Locale(identifier: "en_US")
        
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.author = author
    }
    func getId() -> String {
        return id
    }
    func getTitle() -> String {
        return title
    }
    func getContent() -> String {
        return content
    }
    func getDate() -> TimeInterval {
        return date
    }
    func getAuthor() -> Author {
        return author
    }
    func getDateMMMMd() -> String {
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMMd")
        return dateFormatter.string(from: Date(timeIntervalSince1970: (date)))
    }
    static func == (lhs: Article, rhs: Article) -> Bool {
        return (lhs.getId() == rhs.getId())
    }
}
