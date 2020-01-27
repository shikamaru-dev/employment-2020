//
//  Users.swift
//  JobAssignments
//
//  Created by 村田 司 on 2019/10/25.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import Foundation
import FirebaseFunctions

class Users {
    var userDictionary: Dictionary<String, User> = [:]
    
    func fetch (callback: @escaping () -> Void) {
        let functions = Functions.functions()
        
        functions.httpsCallable("users").call(["userIds": [] ]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                }
            }
            if let users = (result?.data as? [String: Any])?["users"] as? Array<Any> {
                for user in users {
                    let u = user as! NSDictionary
                    let uid = u["uid"] as! String
                    self.userDictionary[uid] = User(
                    uid: uid,
                    displayName: u["displayName"] as? String ?? "",
                    email: u["email"] as? String ?? "")
                }
            }
            callback()
        }
    }
}
