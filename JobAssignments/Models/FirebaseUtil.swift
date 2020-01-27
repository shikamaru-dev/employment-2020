//
//  FirebaseUtil.swift
//  Souji
//
//  Created by 村田 司 on 2019/10/25.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class FirebaseUtil {
    
    static func getDutiesListener(date: String, callback: @escaping (Dictionary<String, String>) -> Void) -> ListenerRegistration? {
        return Firestore.firestore().collection(date + "s").addSnapshotListener { snapshot, e in
            if let snapshot = snapshot {
                var departmentUsers: Dictionary<String, String> = [:]
                for document in snapshot.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let ref = data["user"] as! DocumentReference
                    let departmentRef = data["department"] as! DocumentReference
                    departmentUsers[departmentRef.documentID] = ref.documentID
                }
                callback(departmentUsers)
            }
        }
    }
    
    static func getDutyListener(date: String, departmentId: String, callback: @escaping (String) -> Void) -> ListenerRegistration? {
        return Firestore.firestore().collection(date + "s").document(departmentId).addSnapshotListener { snapshot, e in
            if let snapshot = snapshot {
                let data = snapshot.data()
                let ref = data?["user"] as! DocumentReference
                callback(ref.documentID)
            }
        }
    }
    
    static func getRequestsListener(date: String, callback: @escaping (Array<DepartmentRequest>) -> Void) -> ListenerRegistration? {
        return Firestore.firestore().collection(date  + "Requests").addSnapshotListener { snapshot, e in
            if let snapshot = snapshot {
                
                let requests = snapshot.documents.map { document -> DepartmentRequest in
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let userRef = data["user"] as! DocumentReference
                    let requestUserRef = data["requestUser"] as! DocumentReference
                    let departmentRef = data["department"] as! DocumentReference
                    let approval = data["approval"] as! NSNumber
                    
                    return DepartmentRequest(
                        userId: userRef.documentID,
                        requestUserId: requestUserRef.documentID,
                        departmentId: departmentRef.documentID,
                        approval: approval
                    )
                }
                
                callback(requests)
            }
        }
    }
    
    static func getDepartmentsListener(callback: @escaping (Array<Department>, Dictionary<String, Department>) -> Void) -> ListenerRegistration? {
        return Firestore.firestore().collection("departments").order(by: "priority").addSnapshotListener { snapshot, e in
            if let snapshot = snapshot {
                var departments: [Department] = []
                var departmentDictionaries: Dictionary<String, Department> = [:]
                
                // log
                for document in snapshot.documents {
                    print("\(document.documentID) => \(document.data())")
                }
                departments = snapshot.documents.map{ department -> Department in
                    let data = department.data()
                    let c = Department(
                        id: department.documentID,
                        name: data["name"] as! String,
                        priority: data["priority"] as! String,
                        description: data["description"] as! String,
                        iconUrl: data["icon"] as! String)
                    
                    departmentDictionaries[department.documentID] = c
                    return c
                }
                
                callback(departments,departmentDictionaries)
            }
        }
    }
    
    static func getCandidateListener(date: String, departmentId: String, callback: @escaping (Array<String>) -> Void) -> ListenerRegistration? {
        Firestore.firestore().collection("candidates").document(departmentId).addSnapshotListener { snapshot, e in
            if let snapshot = snapshot {
                var userIds: [String] = []
                let data = snapshot.data()
                let candidateUsers = data?[date + "s"] as! Array<DocumentReference>
                for user in candidateUsers {
                    userIds.append(user.documentID)
                }
                callback(userIds)
            }
        }
    }
    
    static func getDepartmentImages(departments: Array<Department>, callback: @escaping (Dictionary<String, UIImage>) -> Void) {
        var iconDictionaries: Dictionary<String, UIImage> = [:]
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        for department in departments{
            dispatchGroup.enter()
            dispatchQueue.async(group: dispatchGroup) {
                let storage = Storage.storage()
                let storageRef = storage.reference()
                let imageRef = storageRef.child("icons/" + department.iconUrl)
                // 掃除種別に応じたアイコンを取得
                imageRef.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
                    if (error != nil) {
                        print(error ?? "default value")
                        print("Uh-oh, an error occurred!")
                    } else {
                        print("download success!!")
                        iconDictionaries[department.id] = UIImage(data: data!)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            callback(iconDictionaries)
        }
    }
    
    static func getMapImage(departmentId: String, callback: @escaping (UIImage?) -> Void){
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        Firestore.firestore().collection("businessDays").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let timestamp = document["timestamp"] as? Timestamp {
                        let dateFomratter = DateFormatter()
                        dateFomratter.locale = Locale(identifier: "US")
                        dateFomratter.setLocalizedDateFormatFromTemplate("EEE")
                        let date = timestamp.dateValue()
                        if document.documentID == "current" {
                            let weekOfToDay = dateFomratter.string(from: date)
                            let path = String(format:"images/%@/%@.png",departmentId,weekOfToDay)
                            let imageRef = storageRef.child(path)
                            imageRef.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
                                if (error != nil) {
                                    print(error ?? "default value")
                                    print("Uh-oh, an error occurred!")
                                    callback(nil)
                                } else {
                                    print("download success!!")
                                    callback(UIImage(data: data!))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
