//
//  TopTableViewCell.swift
//  JobAssignments
//
//  Created by 曹 一凡 on 2019/10/03.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import UIKit

class TopTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var areaName: UILabel!
    @IBOutlet weak var iconView: UIImageView!

    @IBOutlet weak var arrow: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setData(icon:UIImage,userNameList:String,areaNameList:String) {
        self.iconView.image = icon
        self.userName.text = userNameList
        self.areaName.text = areaNameList
        
    }
}
