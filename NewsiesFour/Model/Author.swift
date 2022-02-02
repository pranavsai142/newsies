//
//  Subscription.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/16/21.
//
import Foundation

struct Author: Identifiable, Equatable, Comparable {
    static func < (lhs: Author, rhs: Author) -> Bool {
        return (lhs.tag <= rhs.tag)
    }
    static func > (lhs: Author, rhs: Author) -> Bool {
        return (lhs.tag > rhs.tag)
    }
    
    var id: String
    var name: String
    var articles: [String]
    var tag: String
    init(id: String, name: String, articles: [String], tag: String) {
        self.id = id
        self.name = name
        self.articles = articles
        self.tag = tag
    }
    func getId() -> String {
        return id
    }
    func getName() -> String {
        return name
    }
    func getArticleUids() -> [String] {
        return articles
    }
    func getTag() -> String {
        return tag
    }
    static func == (lhs: Author, rhs: Author) -> Bool {
        return (lhs.getId() == rhs.getId())
    }
}
