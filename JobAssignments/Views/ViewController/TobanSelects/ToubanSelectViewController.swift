//
//  ToubanSelectViewController.swift
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
import FirebaseFunctions

class ToubanSelectViewController: UIViewController,UIScrollViewDelegate{
    
    let fromAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var currentsListener: ListenerRegistration?
    var departmentArea = UIImage()
    var scrollView:UIScrollView?
    var lastImageView:UIImageView?
    var originalFrame:CGRect!
    let defaultImage = UIImage(named: "nonimage.png")
    
    var department: Department!
    var userDictionaries: Dictionary<String, User> = [:]
    var loginUser = User()
    var currentUser = User()
    var contentOffset = CGPoint.zero
    
    @IBOutlet weak var departmentAreaImage: UIImageView!
    @IBOutlet weak var attention: UITextView!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var btnChangeDesign: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func btnChange(_ sender: Any) {
        
        let title = "toubanSelectAlertTitle".localized
        
        let message = String(format: "toubanSelectAlertMsg".localized, self.currentUser.displayName)
        
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle:  UIAlertController.Style.alert)
        
        let titleFont = [kCTFontAttributeName: UIFont.systemFont(ofSize: 24)]
        let titleAttrString = NSMutableAttributedString(string: title,attributes: titleFont as [NSAttributedString.Key : Any])
        
        
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        
        let messageFont = [kCTFontAttributeName: UIFont.systemFont(ofSize: 17)]
        let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont as [NSAttributedString.Key : Any])
        
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "toubanSelectAlertButtonYes".localized, style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            
            if !self.department.id.isEmpty && !self.loginUser.uid.isEmpty {
                let userRef = Firestore.firestore().collection("users").document(self.loginUser.uid)
                let departmentRef = Firestore.firestore().collection("departments").document(self.department.id)
                Firestore.firestore().collection("currents").document(self.department.id).setData([
                    "department": departmentRef,
                    "user": userRef
                ])
                
                self.currentUser = self.loginUser
                self.labName.text = self.currentUser.displayName
                self.btnChangeDesign.isEnabled = false
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "toubanSelectAlertButtonNo".localized, style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
        })
        // ③ UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        // ④ Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.departmentAreaImage.image = defaultImage
        self.attention.isEditable = false
        self.attention.isSelectable = false
        
        self.departmentAreaImage.isUserInteractionEnabled = true
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.backView.isHidden = true
        
        self.userDictionaries = self.fromAppDelegate.users.userDictionary
        
        //        self.activityIndicator.center = self.departmentAreaImage.center
        
        self.activityIndicator.hidesWhenStopped = true
        // 色を設定
        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        //Viewに追加
        //        self.view.addSubview(activityIndicator)
        //
        self.activityIndicator.startAnimating()
        self.backView.isHidden = false
        self.backView.backgroundColor = UIColor.lightGray
        self.backView.alpha = 0.7
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.attention.contentOffset = self.contentOffset //set
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = self.department.name
        self.attention.text = self.department.description
        
        self.contentOffset = self.attention.contentOffset
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in. Show home screen
                self.loginUser.displayName = user.displayName!
                self.loginUser.email = user.email!
                self.loginUser.uid = user.uid
                if self.currentUser.uid == self.loginUser.uid {
                    // TODO 自分が本日の当番かつ次の当番が決まっていない場合のみ
                    // 次の当番選択を有効化
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.btnChangeDesign.isEnabled = false
                }
            } else {
                // No User is signed in. Show user the login screen
            }
        }
        
        
        FirebaseUtil.getMapImage(departmentId: department.id) {
            image in
            if let mapImage = image {
                // 画像があったときの処理
                self.departmentArea = mapImage
                self.departmentAreaImage.image = self.departmentArea
                
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.showZoomImageView(tap:)))
                self.activityIndicator.stopAnimating()
                self.backView.isHidden = true
                self.departmentAreaImage.addGestureRecognizer(tap)
            } else {
                
                self.activityIndicator.stopAnimating()
                // なかったときの処理
                
            }
        }
        
        self.currentsListener = FirebaseUtil.getDutyListener(date: "current", departmentId: department.id) {
            uid in
            self.labName.text = self.userDictionaries[uid]?.displayName
        }
    }
    
    
    @objc func showZoomImageView( tap : UITapGestureRecognizer) {
        let bgView = UIScrollView.init(frame: UIScreen.main.bounds)
        bgView.backgroundColor = UIColor.black
        let tapBg = UITapGestureRecognizer.init(target: self, action: #selector(tapBgView(tapBgRecognizer:)))
        bgView.addGestureRecognizer(tapBg)
        let picView = tap.view as! UIImageView//
        let imageView = UIImageView.init()
        imageView.image = picView.image;
        imageView.frame = bgView.convert(picView.frame, from: self.view)
        bgView.addSubview(imageView)
        UIApplication.shared.keyWindow?.addSubview(bgView)
        self.lastImageView = imageView
        self.originalFrame = imageView.frame
        self.scrollView = bgView
        self.scrollView?.maximumZoomScale = 1.8
        self.scrollView?.delegate = self
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: UIView.AnimationOptions.beginFromCurrentState,
            animations: {
                var frame = imageView.frame
                frame.size.width = bgView.frame.size.width
                frame.size.height = frame.size.width * ((imageView.image?.size.height)! / (imageView.image?.size.width)!)
                frame.origin.x = 0
                frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5
                imageView.frame = frame
        },
            completion: nil
        )
    }
    
    
    @objc func tapBgView(tapBgRecognizer:UITapGestureRecognizer){
        self.scrollView?.contentOffset = CGPoint.zero
        UIView.animate(withDuration: 0.5, animations: {
            self.lastImageView?.frame = self.originalFrame
            tapBgRecognizer.view?.backgroundColor = UIColor.clear
        })
        {
            (finished:Bool) in
            tapBgRecognizer.view?.removeFromSuperview()
            self.scrollView = nil
            self.lastImageView = nil
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.lastImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var centerX = scrollView.center.x
        var centerY = scrollView.center.y
        
        if scrollView.contentSize.width > scrollView.frame.size.width {
            centerX = scrollView.contentSize.width/2
        }
        if scrollView.contentSize.height > scrollView.frame.size.height {
            centerY = scrollView.contentSize.height/2
        }
        //        centerX = (scrollView.contentSize.width > scrollView.frame.size.width) ?
        //            scrollView.contentSize.width/2:centerX
        //        centerY = (scrollView.contentSize.height > scrollView.frame.size.height) ?
        //            scrollView.contentSize.height/2:centerY
        self.lastImageView?.center = CGPoint(x: centerX, y: centerY)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let next = segue.destination as? NextToubanSelectViewController
        if let next = next {
            next.department = self.department
        }
    }
}
extension ToubanSelectViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        var frame = textView.frame
        frame.size.height = textView.contentSize.height
        textView.frame = frame
    }
}
