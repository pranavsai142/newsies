//
//  DataConglomerate.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/16/21.
//

import Foundation

final class DataConglomerate: ObservableObject {
    @Published var subscriptions = [Author]()
    @Published var data: [String: Any] = [String: Any]()
    @Published var recentArticles: [Article] = [Article]()
    @Published var query: [String: Any] = [String: Any]()
    @Published var foundAuthors = [Author]()
    @Published var authorArticles = [Article]()
    
    func resetValues() {
        subscriptions = [Author]()
        data = [String: Any]()
        recentArticles = [Article]()
        query = [String: Any]()
        foundAuthors = [Author]()
        authorArticles = [Article]()
    }
    func resetQuery() {
        query = [String: Any]()
    }
    func resetSearch() {
        foundAuthors = [Author]()
        authorArticles = [Article]()
    }
    
    func getSortedAuthorArticles() -> [Article] {
        DispatchQueue.main.async {
            self.authorArticles.sort(by: >)
        }
        return authorArticles
    }
    
    func getSortedRecentArticles() -> [Article] {
        DispatchQueue.main.async {
            self.recentArticles.sort(by: >)
        }
        return recentArticles
    }
    
    func getSortedSubscriptions() -> [Author] {
        DispatchQueue.main.async {
            self.subscriptions.sort(by: <)
        }
        return subscriptions
    }
    
    func resetAuthorView() {
        authorArticles = [Article]()
    }
    
    func resetSubscriptions() {
        data = [String: Any]()
        subscriptions = [Author]()
        foundAuthors = [Author]()
        authorArticles = [Article]()
    }
}
