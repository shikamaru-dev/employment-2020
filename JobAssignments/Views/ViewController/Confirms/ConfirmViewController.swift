//
//  ConfirmViewController.swift
//  JobAssignments
//
//  Created by 曹 一凡 on 2019/10/03.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ConfirmViewController: UIViewController {
    
    var candidateUser: User!
    var department: Department!
    var candidateFlag = "next"
    
    private var loginUser = User()
    @IBOutlet weak var departmentNameLabel: UILabel!
    @IBOutlet weak var departmentChargeUsernameLabel: UILabel!
    
    @IBAction func btnOk(_sender:Any){
        
        if(!self.department.id.isEmpty && !self.candidateUser.uid.isEmpty &&  !self.loginUser.uid.isEmpty){
            let userRef = Firestore.firestore().collection("users").document(self.candidateUser.uid)
            let requestUserRef = Firestore.firestore().collection("users").document(self.loginUser.uid)
            let departmentRef = Firestore.firestore().collection("departments").document(self.department.id)
            Firestore.firestore().collection(self.candidateFlag + "Requests").document(self.department.id).setData([
                "requestUser": requestUserRef,
                "department": departmentRef,
                "user": userRef,
                "approval": 0
            ])
        }
        
        
        let title = "confirmTitle".localized
        var dayWord = "confirmDayTom".localized
        if (candidateFlag == "current"){
            dayWord = "confirmDayTod".localized
        }
        let message = dayWord + "confirmMsg".localized
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle:  UIAlertController.Style.alert)
        
        let titleFont = [kCTFontAttributeName: UIFont.systemFont(ofSize: 24)]
        let titleAttrString = NSMutableAttributedString(string: title,attributes: titleFont as [NSAttributedString.Key : Any])
        
        
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        
        
        
        let messageFont = [kCTFontAttributeName: UIFont.systemFont(ofSize: 17)]
        let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont as [NSAttributedString.Key : Any])
        
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "notificationButtonCancel".localized, style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            
            self.navigationController?.popToViewController((self.navigationController!.viewControllers[1]), animated: true)
            
            
            
        })
        
        alert.addAction(defaultAction)
        
        // ④ Alertを表示
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in. Show home screen
                self.loginUser.displayName = user.displayName!
                self.loginUser.email = user.email!
                self.loginUser.uid = user.uid
            } else {
                // No User is signed in. Show user the login screen
            }
        }
        
        self.departmentChargeUsernameLabel.text = self.candidateUser.displayName
        self.departmentNameLabel.text = self.department.name
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

