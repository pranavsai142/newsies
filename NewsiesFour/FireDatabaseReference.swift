//
//  FireDatabaseReference.swift
//  NewsiesFour
//
//  Created by Pranav Sai on 1/14/21.
//

import Foundation
import FirebaseDatabase

final class FireDatabaseReference: ObservableObject {
    @Published var database: DatabaseReference = Database.database().reference()
    
    func getReference() -> DatabaseReference {
        return database
    }
    
    func setValue(path: [String], value: Any) {
        let stringPath = path.joined(separator: "/")
        database.child(stringPath).setValue(value)
    }
    func removeValue(path: [String]) {
        let stringPath = path.joined(separator: "/")
        database.child(stringPath).removeValue()
    }
    
    func getValue(path: [String], key: String, tag: String, dataConglomerate: DataConglomerate) -> Bool {
        let stringPath = path.joined(separator: "/")
        let ref = database.child(stringPath)
//        var data: Any?
//        print("Query")
//        print(stringPath)
//        print(key)
        if(dataConglomerate.data[tag] == nil) {
            ref.observeSingleEvent(of: .value, with: { snapshot in
              // This is the snapshot of the data at the moment in the Firebase database
              // To get value from the snapshot, we user snapshot.value
    //            print("INISIDE")
    //            print(snapshot.value!)
    //            print("\(type(of: snapshot.value))")
    //            print(self.data)
                if(snapshot.value! is NSNull) {
                    dataConglomerate.data[tag] = "DNE"
                } else {
                    dataConglomerate.data[tag] = ((snapshot.value) as! NSDictionary)[key]
                }
            })
        }
        return true
    }
    
    func getValues(path: [String], tag: String, dataConglomerate: DataConglomerate) -> Bool {
        let stringPath = path.joined(separator: "/")
        let ref = database.child(stringPath)
//        var data: Any?
//        print(stringPath)
//        print(key)
        if(dataConglomerate.data[tag] == nil) {
            ref.observeSingleEvent(of: .value, with: { snapshot in
              // This is the snapshot of the data at the moment in the Firebase database
              // To get value from the snapshot, we user snapshot.value
                var data = NSArray()
                for snap in snapshot.children {
                    let value = (snap as! DataSnapshot).key
                    data = data.adding(value) as NSArray
                }
                dataConglomerate.data[tag] = data
            })
        }
        return true
    }
    
    func getList(path: [String], tag: String, dataConglomerate: DataConglomerate) -> Bool {
        let stringPath = path.joined(separator: "/")
        let ref = database.child(stringPath)
//        var data: Any?
//        print(stringPath)
        if(dataConglomerate.data[tag] == nil) {
            ref.observeSingleEvent(of: .value, with: { snapshot in
              // This is the snapshot of the data at the moment in the Firebase database
              // To get value from the snapshot, we user snapshot.value
//                print("INISIDE")
//                print(values)
//                print("\(type(of: values))")
                if(snapshot.value! is NSNull) {
                    dataConglomerate.data[tag] = "DNE"
                }
                else {
                    dataConglomerate.data[tag] = (snapshot.value) as! NSDictionary
                }
            })
        }
        return true
    }
    
    func queryDatabaseForString(path: [String], child: String, query: String, foundTag: String, tag: String, dataConglomerate: DataConglomerate) -> Bool {
        var ref = database
        if(path.count > 0) {
            let stringPath = path.joined(separator: "/")
//            print(stringPath)
            ref = database.child(stringPath)
        }
//        print("query")
        ref.queryOrdered(byChild: child).queryEqual(toValue: query).observeSingleEvent(of: .value, with: { snapshot in
            if let snapVal = snapshot.value as? NSArray {
//                print("cauht array")
                dataConglomerate.query[foundTag] = true
                var authorUUID = ""
                for snap in snapshot.children {
                    authorUUID = (snap as! DataSnapshot).key
                }
//                print("found tag", foundTag)
//                print("AUTHOr UUID", authorUUID)
//                print("snapVAl", snapVal[1])
                let authorData = NSArray(array: [authorUUID]).addingObjects(from: [snapVal[1]])
//                print("AUTHOr DATA", authorData)
                dataConglomerate.query[tag] = authorData
            }
            else if let snapVal = snapshot.value as? NSDictionary {
//                print("cauht dictionary")
                dataConglomerate.query[foundTag] = true
//                print("found tag", foundTag)
                dataConglomerate.query[tag] = snapVal
            }
            else {
//                print("NO DICE")
                dataConglomerate.query[foundTag] = false
                dataConglomerate.query[tag] = false
            }
//            for snap in snapshot.children {
//                print((snap as! DataSnapshot).key)
//            }
        })
        return true
    }
}

