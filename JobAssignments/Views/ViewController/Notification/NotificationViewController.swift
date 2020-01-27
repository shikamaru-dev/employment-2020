//
//  NotificationViewController.swift
//  JobAssignments
//
//  Created by 曹 一凡 on 2019/10/17.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class NotificationViewController: UIViewController, UINavigationControllerDelegate {
    
    var loginUser = User()
    
    var departments: [Department] = []
    var iconDictionaries: Dictionary<String, UIImage> = [:]
    
    var requestDepartment: Department!
    var requestUser: User!
    // next or current
    var requestFlag = "next"
    
    @IBOutlet weak var departmentNameLabel: UILabel!
    @IBOutlet weak var departmentChargeUsernameLabel: UILabel!
    
    @IBAction func btnNo(_ sender: Any) {
        
        // リクエストを断る
        if(!self.requestDepartment.id.isEmpty && !self.requestUser.uid.isEmpty &&  !self.loginUser.uid.isEmpty){
            Firestore.firestore().collection(self.requestFlag + "Requests").document(self.requestDepartment.id).updateData([
                "approval": 2
            ])
        }
        
        self.navigationController?.popToViewController((self.navigationController!.viewControllers[1]), animated: true)
    }
    
    @IBAction func btnYes(_ sender: Any) {
        
        // リクエストを受ける
        if(!self.requestDepartment.id.isEmpty && !self.requestUser.uid.isEmpty &&  !self.loginUser.uid.isEmpty){
            Firestore.firestore().collection(self.requestFlag + "Requests").document(self.requestDepartment.id).updateData([
                "approval": 1
            ])
        }
        
        let title = "notificationAlertTitle".localized
        
        let message = "notificationAlertMsg".localized
        
        let _alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle:  UIAlertController.Style.alert)
        
        let titleFont = [kCTFontAttributeName: UIFont.systemFont(ofSize: 24)]
        let titleAttrString = NSMutableAttributedString(string: title,attributes: titleFont as [NSAttributedString.Key : Any])
        
        
        _alert.setValue(titleAttrString, forKey: "attributedTitle")
        
        let messageFont = [kCTFontAttributeName: UIFont.systemFont(ofSize: 17)]
        let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont as [NSAttributedString.Key : Any])
        
        _alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "notificationButtonCheck".localized, style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            self.navigationController?.popToViewController((self.navigationController!.viewControllers[1]), animated: false)
            let modal = TommorowViewController()
            modal.departments = self.departments
            modal.iconDictionaries = self.iconDictionaries
            modal.modalPresentationStyle = .custom
            modal.transitioningDelegate = self
            modal.btnChangeFlg = true
            
            self.present(modal, animated: true, completion: nil)
            
            
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "notificationButtonCancel".localized, style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            self.navigationController?.popToViewController((self.navigationController!.viewControllers[1]), animated: true)
            
            //                self.performSegue(withIdentifier: "backtoTop", sender: nil)
            
            print("Cancel")
        })
        
        // ③ UIAlertControllerにActionを追加
        _alert.addAction(cancelAction)
        _alert.addAction(defaultAction)
        
        // ④ Alertを表示
        present(_alert, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.delegate = self
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in. Show home screen
                self.loginUser.displayName = user.displayName!
                self.loginUser.email = user.email!
                self.loginUser.uid = user.uid
                
                self.departmentChargeUsernameLabel.text = self.loginUser.displayName
            } else {
                // No User is signed in. Show user the login screen
            }
        }
        self.departmentNameLabel.text = self.requestDepartment.name
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
extension NotificationViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
