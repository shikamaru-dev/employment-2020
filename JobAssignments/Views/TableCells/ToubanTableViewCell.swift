//
//  ToubanTableViewCell.swift
//  Souji
//
//  Created by 曹 一凡 on 2019/10/03.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import UIKit

class ToubanTableViewCell: UITableViewCell {
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setData(date:String,name:String) {
        self.date.text = date
        self.name.text = name
        
    }
}
