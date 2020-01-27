//
//  AllpeopleTableViewCell.swift
//  JobAssignments
//
//  Created by 曹 一凡 on 2019/10/04.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import UIKit

class AllpeopleTableViewCell: UITableViewCell {
    @IBOutlet weak var allPeople: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setData(allPeopleName:String) {
        
        self.allPeople.text = allPeopleName
        
    }
    
    
}
