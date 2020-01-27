//
//  NextToubanSelectViewController.swift
//  JobAssignments
//
//  Created by 曹 一凡 on 2019/10/03.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

class NextToubanSelectViewController: UIViewController {
    
    let fromAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let number = ["☆","",""]
    
    @IBOutlet weak var nextTable: UITableView!
    
    var department: Department!
    var candidateUsers: [User] = []
    var userDictionaries: Dictionary<String, User> = [:]
    
    private var candidateListener: ListenerRegistration?
    
    // current or next
    var candidateFlag = "next"
    
    @IBAction func BtnAll(_sender:Any){
        performSegue(withIdentifier: "toAllPeople", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextTable.register(UINib(nibName: "NextTableViewCell", bundle: nil), forCellReuseIdentifier: "Identifier")
        self.nextTable.tableFooterView = UIView()
        self.userDictionaries = self.fromAppDelegate.users.userDictionary
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.candidateListener = FirebaseUtil.getCandidateListener(date: self.candidateFlag, departmentId: department.id) {
            userIds in
            self.candidateUsers.removeAll()
            for uid in userIds {
                if let u = self.userDictionaries[uid] {
                    self.candidateUsers.append(u)
                }
            }
            self.nextTable.reloadData()
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let next = segue.destination as? AllPeopleViewController
        if let next = next {
            next.department = self.department
            next.candidateUsers = self.candidateUsers
            next.candidateFlag = self.candidateFlag
        }
        
        let nextConfirmView = segue.destination as? ConfirmViewController
        if let next = nextConfirmView {
            let row = sender as! Int
            next.department = self.department
            next.candidateUser = self.candidateUsers[row]
            next.candidateFlag = self.candidateFlag
        }
    }
}
extension NextToubanSelectViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ひとまず今回は10件のみ表示とする
        return min(self.number.count,self.candidateUsers.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // forCellReuseIdentifierに設定したIdentifierを指定
        let cell = tableView.dequeueReusableCell(withIdentifier: "Identifier", for: indexPath) as! NextTableViewCell
        cell.setData(
            strNumber:self.number[indexPath.row],
            strName:self.candidateUsers[indexPath.row].displayName
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルの選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "toConfirm", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1 //お好きな高さに
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.groupTableViewBackground //お好きな色に
        return view
    }
}
