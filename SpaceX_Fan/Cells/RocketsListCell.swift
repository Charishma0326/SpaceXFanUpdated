//
//  RocketsListCell.swift
//  SpaceX_Fan
//
//  Created by YeshwantSatya on 05/08/21.
//

import UIKit

class RocketsListCell: UITableViewCell {

    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var flightNum: UILabel!
    @IBOutlet weak var rocketLncDt: UILabel!
    @IBOutlet weak var rocketName: UILabel!
    @IBOutlet weak var tbImgRef: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
