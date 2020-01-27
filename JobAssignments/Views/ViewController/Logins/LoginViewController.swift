//
//  LoginViewController.swift
//  JobAssignments
//
//  Created by 曹 一凡 on 2019/10/03.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import KeychainAccess

class LoginViewController: UIViewController {
    
    let fromAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var btnLoginDesign: UIButton!
    
    let keychain = Keychain()
    
    @IBAction func BtnLogin(_ sender: Any) {
        if let e = email?.text,let p = password?.text{
            Auth.auth().signIn(withEmail: e, password: p) { [weak self] user, error in
                guard let strongSelf = self else { return }
                // ...
                if error != nil{
                    let alert = UIAlertController(title: "loginAlertTitle".localized, message: "loginAlertMsg".localized, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "loginOk".localized, style: UIAlertAction.Style.default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
                if let u = user {
                    // tokenをサーバーに送信
                    if let token = self?.fromAppDelegate.fcmToken {
                        Firestore.firestore().collection("users").document(u.user.uid).setData([
                            "token": token
                        ], merge: true)
                    }
                    // 次の画面へ遷移
                    do {
                        try self?.keychain.set(e, key: "email")
                    } catch {
                    }
                    do {
                        try self?.keychain.set(p, key: "password")
                    } catch {
                    }
                    print(u.user.email ?? "")
                    strongSelf.performSegue(withIdentifier: "toTopView", sender: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        var email = ""
        var password = ""
        do{
            try email = self.keychain.getString("email") ?? ""
            try password = self.keychain.getString("password") ?? ""
        } catch {}
        
        if(!email.isEmpty && !password.isEmpty){
            self.email.text = email
            self.password.text = password
            // TODO ログインボタンクリック....
        }
        self.email.delegate = self
        self.password.delegate = self
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        configureObserver()  //Notification発行
    }
    
    func configureObserver() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                 name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                 name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //キーボードが表示時に画面をずらす。
    @objc func keyboardWillShow(notification: Notification?) {
        
        let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            let transform = CGAffineTransform(translationX: 0, y: -((rect?.size.height)! - 180))
            self.view.transform = transform
            
        })
    }
    // キーボードが降りたら画面を戻す
    @objc func keyboardWillHide(notification: Notification?) {
        
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            
            self.view.transform = CGAffineTransform.identity
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        password.resignFirstResponder()
        return true
    }
}
