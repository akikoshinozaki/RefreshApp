//
//  DetailTableViewCell.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/06/01.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    @IBOutlet var koteiLabel:UILabel!
    @IBOutlet var dateLabel:UILabel!
    @IBOutlet var tantoLabel:UILabel!
    
    @IBOutlet var juryoLabel:UILabel!
    @IBOutlet var tempLabel:UILabel!
    @IBOutlet var humidLabel:UILabel!
    @IBOutlet var weatherLabel:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
