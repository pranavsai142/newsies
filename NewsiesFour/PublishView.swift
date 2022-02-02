//
//  PublishView.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/18/21.
//

import SwiftUI

struct PublishView: View {
    var uid: String
    @EnvironmentObject var database: FireDatabaseReference
    @EnvironmentObject var dataConglomerate: DataConglomerate
//    @EnvironmentObject var obj: observed
    @State private var articleTitle = ""
    @State private var articleContent = "replace this text with content"
    @State private var authorTag = ""
    @State private var authorName = ""
    @State private var isPublished = false
    @State private var publishButtonHit = false
    @State private var failedToPublish = false
    @State private var tagExists = false
    var body: some View {
        if(listenForQueryCompletionAndPublish()) {
            VStack {
                //This text field should be made immutable
                TextField("@tag", text: $authorTag)
                //Maybe this one too
                TextField("author name", text: $authorName)
                TextField("title", text: $articleTitle)
                TextEditor(text: $articleContent)
                Spacer()
    //            MultiTextField()
    //                .frame(height: self.obj.size)
    //                .padding()
    //                .background(Color.yellow)
    //            Button(action: {
    //                publish()
    //            }) {
    //                if(!queryListener) {
    //                    Text("Publish")
    //                }
    //                else {
    //                    Text("Published!")
    //                }
    //            }
                if(tagExists) {
                    Text("Tag already exists")
                } else if(failedToPublish) {
                    Text("Incorrect tag")
                }
                NavigationLink(
                    destination: FeedView(uid: uid)
                        .environmentObject(database)
                        .environmentObject(dataConglomerate),
                    isActive: $isPublished) {
                    Button(action: {
                        publish()
                    }) {
    //                    If publish button not hit and is not failed to publish
                        if(!failedToPublish && !publishButtonHit) {
                            Text("publish")
    //                        If the publish button was hit
                        } else if (publishButtonHit && !failedToPublish) {
                            Text("processing...")
                        }
    //                    If the publish button was reset and therer was no fail to publish
                        else if (!failedToPublish) {
                            Text("published!")
                        }
                        else {
                            Text("publish")
                        }
                    }
                }
            }
            .padding()
        }
    }
//        VStack {
//            Text("QUICKLY PUBLISH CONTENT TO THE SERVER. REQUIRED MATERIAL: TITLE, CONTENT, AUTHOR TITLE, AUTHOR TAG")
//            Text("If a given tag already exists in the database, add article as authored by that tag. Otherwise create a new uuid for a subscription in the database and create a profile under the subscriptions branch (would be nice if renamed to authors)")
//        }
    
    private func publish() {
        dataConglomerate.resetQuery()
        publishButtonHit = true
        failedToPublish = false
        tagExists = false
        authorTag = authorTag.lowercased()
        if(authorTag.hasPrefix("@")) {
            let queryFoundTag = "query_" + authorTag + "_found"
            let queryTag = "query_" + authorTag + "_tag"
            if(database.queryDatabaseForString(path: ["authors"], child: "tag", query: authorTag, foundTag: queryFoundTag, tag: queryTag, dataConglomerate: dataConglomerate)) {
                failedToPublish = false
            }
            else {
                failedToPublish = true
            }
        } else {
            failedToPublish = true
        }
    }
    
    private func listenForQueryCompletionAndPublish() -> Bool {
        if(publishButtonHit && !failedToPublish) {
//            print("HFHHF")
            let queryFoundTag = "query_" + authorTag + "_found"
            if(dataConglomerate.query[queryFoundTag] != nil) {
                DispatchQueue.main.async {
//                    print("gegege")
                    let resultFound = dataConglomerate.query[queryFoundTag] as! Bool
                    if(resultFound) {
//                        print("FOUND")
                        isPublished = uploadExistingAuthorContent()
                        publishButtonHit = false
                        dataConglomerate.resetQuery()
                    }
                    else {
                        isPublished = uploadNewAuthorContent()
                        publishButtonHit = false
                        dataConglomerate.resetQuery()
                    }
                }
            }
        }
        return true
    }
    
    
    
    //If user is trying to publish an article with an existing user tag, this function is called
    private func uploadExistingAuthorContent() -> Bool {
        let queryTag = "query_" + authorTag + "_tag"
        let authorData = dataConglomerate.query[queryTag]
        //authorDictionary holds all the info
        var authorDictionary : NSDictionary
        var authorUID = ""
        //Conditional to handle firebase quirk. If author is the first entry it is represented as an NSArray, if it is
        //any other entry other than the first it is an NSdictionary.
        //seems hard to pull uuid from author entry if it is the first one. Going to hardcode in the first author
        //in the database so this isint a problem.
        if authorData is NSArray {
            let authorArray = authorData as! NSArray
            authorUID = authorArray[0] as! String
//            print("uIdUID", authorUID)
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
//        let publishedArticles = (authorDictionary["articles"] as! NSDictionary).allKeys
//        print(publishedArticles)
//        print(authorDictionary["name"] as! String)
//        print(authorDictionary["tag"] as! String)
        if(authorUID == uid) {
            let articleUID = UUID().uuidString
            let articleDate = NSDate().timeIntervalSince1970
//            print("ARTICLE UUID", articleUID)
//            print("articleDATE", articleDate)
    //      create article in articles branch
            database.setValue(path: ["articles", articleUID, "date"] , value: articleDate)
            database.setValue(path: ["articles", articleUID, "title"] , value: articleTitle)
            database.setValue(path: ["articles", articleUID, "content"] , value: articleContent)
    //      rewrite author name based on authorName state varaiable
            database.setValue(path: ["authors", authorUID, "name"], value: authorName)
    //      Add article uuid to authors list
            database.setValue(path: ["authors", authorUID, "articles", articleUID], value: true)
            return true
        } else {
            tagExists = true
            failedToPublish = true
            return false
        }
    }
    
    private func uploadNewAuthorContent() -> Bool {
//        print("wewew")
        //create article in articles branch
        let articleUID = UUID().uuidString
        let articleDate = NSDate().timeIntervalSince1970
//        Change this
//        let authorUUID = UUID().uuidString
//        To this
        let authorUID = uid
//        print("ARTICLE UID", articleUID)
//        print("articleDATE", articleDate)
//      create article in articles branch
        database.setValue(path: ["articles", articleUID, "date"] , value: articleDate)
        database.setValue(path: ["articles", articleUID, "title"] , value: articleTitle)
        database.setValue(path: ["articles", articleUID, "content"] , value: articleContent)
        
        //create new author branch with specified tag
        database.setValue(path: ["authors", authorUID, "tag"], value: authorTag)
        //add in author name based onn state variable
        database.setValue(path: ["authors", authorUID, "name"], value: authorName)
        //add article uuid to author article list
        database.setValue(path: ["authors", authorUID, "articles", articleUID], value: true)
        return true
    }
}

struct PublishView_Previews: PreviewProvider {
    static var previews: some View {
        PublishView(uid: "yca5i8BSWaMRW8ci11Xe8SKB7Cj2")
            .environmentObject(FireDatabaseReference())
            .environmentObject(DataConglomerate())
//            .environmentObject(observed())
    }
}

//struct MultiTextField: UIViewRepresentable {
//    func makeCoordinator() -> MultiTextField.Coordinator {
//        return MultiTextField.Coordinator(parent1: self)
//    }
//
//    @EnvironmentObject var obj: observed
//    func makeUIView(context: UIViewRepresentableContext<MultiTextField>) -> UITextView {
//        let view = UITextView()
//        view.font = .systemFont(ofSize: 19)
//        view.text = "Type something"
//        view.textColor = UIColor.black.withAlphaComponent(0.35)
//        view.backgroundColor = .clear
//        view.delegate = context.coordinator
//
//        self.obj.size = view.contentSize.height
//        view.isEditable = true
//        view.isUserInteractionEnabled = true
//        view.isScrollEnabled = true
//        return view
//    }
//
//    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<MultiTextField>) {
//
//    }
//
//    class Coordinator: NSObject, UITextViewDelegate {
//        var parent: MultiTextField
//        init(parent1: MultiTextField) {
//            parent = parent1
//        }
//
//        func textViewDidBeginEditing(_ textView: UITextView) {
//            textView.text = ""
//            textView.textColor = .black
//        }
//
//        func textViewDidChange(_ textView: UITextView) {
//            self.parent.obj.size = textView.contentSize.height
//        }
//    }
//}
//
//class observed: ObservableObject {
//    @Published var size : CGFloat = 0
//}
