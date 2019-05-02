//
//  OptionTableViewCell.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 5/2/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit

class OptionTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
