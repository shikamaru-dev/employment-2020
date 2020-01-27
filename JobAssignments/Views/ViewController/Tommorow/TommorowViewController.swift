//
//  TommorowViewController.swift
//  JobAssignments
//
//  Created by 曹 一凡 on 2019/10/04.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseFunctions

class TommorowViewController: UIViewController, UINavigationControllerDelegate {
    
    let fromAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var tommorowTable: UITableView!
    @IBOutlet weak var btnChangeDesign: UIButton!
    
    var ownDepartment: Department?
    var departments: [Department] = []
    var userDictionaries: Dictionary<String, User> = [:]
    var iconDictionaries: Dictionary<String, UIImage> = [:]
    
    var departmentUsers: Dictionary<String, String> = [:]
    private var nextsListener: ListenerRegistration?
    private var loginUser = User()
    
    private var userNameDictionaries: Dictionary<String, String> = [:]
    var btnChangeFlg = false
    
    let defaultIcon = UIImage(named:"loading.png")
    
    let highLightBorderColor = UIColor(red: 255.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
    let hightLightBackGroundColor = UIColor(red: 255/255.0, green: 240/255.0, blue: 245/255.0, alpha: 1.0)
    let defaultBoderColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0).cgColor
    let defaultBackgroundColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
    
    @IBAction func BtnClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnChange(_ sender: Any) {
        guard let nc = self.presentingViewController as? UINavigationController else { return }
        guard let top = nc.viewControllers[nc.viewControllers.count - 1] as? TopViewController else { return }
        self.dismiss(animated: true) {
            if let department = self.ownDepartment {
                top.toNext(department: department)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tommorowTable.register(UINib(nibName: "TopTableViewCell", bundle: nil), forCellReuseIdentifier: "Identifier")
        self.tommorowTable.tableFooterView = UIView()
        navigationController?.delegate = self
        btnChangeDesign.isHidden = btnChangeFlg
        self.userDictionaries = self.fromAppDelegate.users.userDictionary
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
        // 翌営業日の掃除情報を取得
        self.nextsListener = FirebaseUtil.getDutiesListener(date: "next") {
            dic in
            self.ownDepartment = nil
            self.departmentUsers = dic
            self.tommorowTable.reloadData()
        }
        
    }
    
}
extension TommorowViewController : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // forCellReuseIdentifierに設定したIdentifierを指定
        let cell = tableView.dequeueReusableCell(withIdentifier: "Identifier", for: indexPath) as! TopTableViewCell
        let departmentId = self.departments[indexPath.row].id
        let departmentUser = self.departmentUsers[departmentId] ?? ""
        cell.setData(
            icon:self.iconDictionaries[departmentId] ?? defaultIcon!,
            userNameList:self.userDictionaries[departmentUser]?.displayName ?? "topViewUnknown".localized,
            areaNameList:self.departments[indexPath.row].name)
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = defaultBoderColor
        
        if cell.userName.text == loginUser.displayName {
            // ログイン中のユーザーが存在する場合
            self.ownDepartment = self.departments[indexPath.row]
            cell.layer.borderWidth = 2
            cell.layer.borderColor = highLightBorderColor
            cell.backgroundColor = hightLightBackGroundColor
            
        }
        else{
            cell.layer.borderColor = defaultBoderColor
            cell.layer.borderWidth = 1
            cell.backgroundColor = UIColor.white
        }
        
        self.btnChangeDesign.isHidden = self.ownDepartment == nil
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 1 //お好きな高さに
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = defaultBackgroundColor
        return view
    }
}
