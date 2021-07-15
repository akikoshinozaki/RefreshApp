//
//  YakanTableViewCell.swift
//  RefreshApp
//
//  Created by administrator on 2021/07/14.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

class YakanTableViewCell: UITableViewCell {

    @IBOutlet weak var entryLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var koteiLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var g_Label: UILabel!
    @IBOutlet weak var s_Label: UILabel!
    @IBOutlet weak var tantoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
