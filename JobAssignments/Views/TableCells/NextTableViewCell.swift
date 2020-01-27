//
//  NextTableViewCell.swift
//  JobAssignments
//
//  Created by 曹 一凡 on 2019/10/08.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import UIKit

class NextTableViewCell: UITableViewCell {
    
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setData(strNumber:String,strName:String) {
        self.number.text = strNumber
        self.name.text = strName
        
    }
    
}
