//
//  AllPeopleViewController.swift
//  JobAssignments
//
//  Created by 曹 一凡 on 2019/10/04.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import UIKit
import FirebaseAuth

class AllPeopleViewController: UIViewController{
    
    //    @IBAction func btnclose(_ sender: Any) {
    //        self.dismiss(animated: true, completion: nil)
    //    }
    
    var department: Department!
    var candidateUsers: [User] = []
    var candidateFlag = "next"
    
    @IBOutlet weak var allPeopleTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allPeopleTable.register(UINib(nibName: "AllpeopleTableViewCell", bundle: nil), forCellReuseIdentifier: "Identifier")
        self.allPeopleTable.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
}
extension AllPeopleViewController :UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ひとまず今回は10件のみ表示とする
        return candidateUsers.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // forCellReuseIdentifierに設定したIdentifierを指定
        let cell = tableView.dequeueReusableCell(withIdentifier: "Identifier", for: indexPath) as! AllpeopleTableViewCell
        cell.setData(
            allPeopleName: candidateUsers[indexPath.row].displayName
        )
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルの選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "allToConfirm", sender: indexPath.row)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let next = segue.destination as? ConfirmViewController
        if let next = next {
            let row = sender as! Int
            next.department = self.department
            next.candidateUser = self.candidateUsers[row]
            next.candidateFlag = self.candidateFlag
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
    
}
