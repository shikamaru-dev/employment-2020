//
//  TopViewController.swift
//  Souji
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

class TopViewController: UIViewController {
    
    let fromAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var departmentListener: ListenerRegistration?
    private var currentsListener: ListenerRegistration?
    
    private var nextRequestsListener: ListenerRegistration?
    private var currentRequestsListener: ListenerRegistration?
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnNextDesign: UIButton!
    
    let highLightBorderColor = UIColor(red: 255.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
    let highLightBackgroundColor = UIColor(red: 255/255.0, green: 240/255.0, blue: 245/255.0, alpha: 1.0)
    let defaultColor =  UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
    let defaultBorderColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0).cgColor
    @IBOutlet weak var backgroundView: UIView!
    var iconDictionaries: Dictionary<String, UIImage> = [:]
    var userDictionaries: Dictionary<String, User> = [:]
    var departmentUsers: Dictionary<String, String> = [:]
    let defaultIcon = UIImage(named:"loading.png")
    
    var departments: [Department] = []
    var departmentDictionaries: Dictionary<String, Department> = [:]
    var loginUser = User()
    
    var currentRequest: DepartmentRequest?
    var nextRequest: DepartmentRequest?
    
    var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func btnNext (_sender:UIButton){
        let modal = TommorowViewController()
        modal.departments = self.departments
        modal.iconDictionaries = self.iconDictionaries
        modal.modalPresentationStyle = .custom
        modal.transitioningDelegate = self
        present(modal, animated: true, completion: nil)
        
        
    }
    
    @objc func noti(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toNoti", sender: nil)
    }
    
    lazy var rightButton: BadgeBarButtonItem = {
        let bellbtn = UIButton(type:.detailDisclosure)
        
        bellbtn.frame = CGRect(x: 0, y: 0, width: 25, height: 30)
        bellbtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        bellbtn.addTarget(self, action:#selector(TopViewController.noti(_:)), for: .touchDown)
        let rightButton = BadgeBarButtonItem(customButton: bellbtn)
        rightButton.badgeValue = "1";
        return rightButton
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.applicationIconBadgeNumber = 1
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "TopTableViewCell", bundle: nil), forCellReuseIdentifier: "Identifier")
        
        self.backgroundView.isHidden = true
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        let rb = self.navigationItem.rightBarButtonItem as! BadgeBarButtonItem
        rb.badgeValue = "0"
        
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator.center = self.view.center
        
        self.activityIndicator.hidesWhenStopped = true
        // 色を設定
        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        //Viewに追加
        self.view.addSubview(activityIndicator)
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.authHandle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in. Show home screen
                self.loginUser.displayName = user.displayName!
                self.loginUser.email = user.email!
                self.loginUser.uid = user.uid
            } else {
                // No User is signed in. Show user the login screen
            }
        }
        // ユーザー一覧取得
        fromAppDelegate.users.fetch {
            
            self.userDictionaries = self.fromAppDelegate.users.userDictionary
            self.tableView.reloadData()
        }
        
        // 本日の任務情報を取得
        self.currentsListener = FirebaseUtil.getDutiesListener(date: "current") {
            dic in
            self.departmentUsers = dic
            self.tableView.reloadData()
        }
        
        self.departmentListener = FirebaseUtil.getDepartmentsListener {
            arr, dic in
            self.departmentDictionaries = dic
            self.departments = arr
            self.tableView.reloadData()
            // 画像読み込み
            FirebaseUtil.getDepartmentImages(departments: arr) {
                iconDic in
                self.iconDictionaries = iconDic
                self.tableView.reloadData()

            }
        }
        
        // 本日の自分宛のリクエストを取得
        self.currentRequestsListener = FirebaseUtil.getRequestsListener(date: "current") {
            arr in
            let rb = self.navigationItem.rightBarButtonItem as! BadgeBarButtonItem
            
            for request in arr {
                if(request.userId == self.loginUser.uid && request.approval == 0){
                    self.currentRequest = request
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    rb.badgeValue = "1"
                    return
                }
            }
            self.currentRequest = nil
            if(self.nextRequest == nil) {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                rb.badgeValue = "0"
            }
        }
        
        self.nextRequestsListener = FirebaseUtil.getRequestsListener(date: "next") {
            arr in
            let rb = self.navigationItem.rightBarButtonItem as! BadgeBarButtonItem
            
            for request in arr {
                if(request.userId == self.loginUser.uid && request.approval == 0){
                    self.nextRequest = request
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    rb.badgeValue = "1"
                    return
                }
            }
            self.nextRequest = nil
            if(self.currentRequest == nil) {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                rb.badgeValue = "0"
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(authHandle!)
        self.departmentListener?.remove()
        self.currentsListener?.remove()
        self.nextRequestsListener?.remove()
        self.currentRequestsListener?.remove()
    }
    
    func toNext(department: Department){
        self.performSegue(withIdentifier: "topToNext", sender: department)
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
extension TopViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension TopViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // forCellReuseIdentifierに設定したIdentifierを指定
        let cell = tableView.dequeueReusableCell(withIdentifier: "Identifier", for: indexPath) as! TopTableViewCell
        
        let departmentId = self.departments[indexPath.row].id
        let departmentUser = self.departmentUsers[departmentId] ?? ""
        cell.setData(
            icon:self.iconDictionaries[departmentId] ?? defaultIcon!,
            userNameList:self.userDictionaries[departmentUser]?.displayName ?? "topViewUnknown".localized,
            areaNameList:self.departments[indexPath.row].name)
        
        cell.arrow.isHidden = false
        
        if cell.userName.text == "topViewUnknown".localized {
            
            self.activityIndicator.startAnimating()
            self.backgroundView.isHidden = false
            self.backgroundView.backgroundColor = UIColor.lightGray
            self.backgroundView.alpha = 0.7
            
        }
        else {
            
            self.activityIndicator.stopAnimating()
            self.backgroundView.isHidden = true
        }
        
        if cell.userName.text == loginUser.displayName {
            
            cell.layer.borderWidth = 2
            cell.layer.borderColor = highLightBorderColor
            cell.backgroundColor = highLightBackgroundColor
            
        }
        else{
            cell.layer.borderColor = defaultBorderColor
            cell.layer.borderWidth = 1
            cell.backgroundColor = UIColor.white
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = defaultColor //お好きな色に
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 1 //お好きな高さに
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.departments.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルの選択解除
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "toToubanSelect", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let next = segue.destination as? ToubanSelectViewController
        if let next = next {
            let row = sender as! Int
            let departmentId = self.departments[row].id
            let departmentUser = self.departmentUsers[departmentId] ?? ""
            print(self.departments[row].id)
            print(self.departments[row].name)
            next.department = self.departments[row]
            next.currentUser = self.userDictionaries[departmentUser]!
        }
        
        let nextNotification = segue.destination as? NotificationViewController
        if let next = nextNotification {
            
            if(self.currentRequest != nil){
                next.requestDepartment = self.departmentDictionaries[self.currentRequest!.departmentId]
                next.requestFlag = "current"
                next.requestUser = self.userDictionaries[self.currentRequest!.requestUserId]
            } else {
                next.requestDepartment = self.departmentDictionaries[self.nextRequest!.departmentId]
                next.requestFlag = "next"
                next.requestUser = self.userDictionaries[self.nextRequest!.requestUserId]
            }
            
            next.departments = self.departments
            next.iconDictionaries = self.iconDictionaries
        }
        
        let nextNextTouban = segue.destination as? NextToubanSelectViewController
        if let next = nextNextTouban {
            let c = sender as! Department
            next.department = c
        }
    }
}
