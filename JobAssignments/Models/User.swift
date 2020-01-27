//
//  User.swift
//  JobAssignments
//
//  Created by 村田 司 on 2019/10/25.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import Foundation

class User {
    var uid: String = ""
    var displayName: String = ""
    var email: String = ""
    
    init(){}
    
    init(uid: String, displayName: String, email: String) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
    }
    
}
